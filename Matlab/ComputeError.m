

clear;
%fileInNameTruth  = 'data\\CameraSpacetrackingNullOut.txt';
%fileInNameDisp   = 'data\\trackingDisplacement.txt';
%fileInNameExtra  = 'data\\trackingExtrapolation.txt';
%fileInNameSpring = 'data\\trackingSpring.txt';

fileOut = fopen('Evaluation4.csv','a');

filedir ='C:\Users\MultiPeden\Documents\GitHub\ScreenTrackerEvaluation\results\log';
printEvaluationToFile(fileOut,filedir)


fclose(fileOut);


%%


function []  = printEvaluationToFile(fileOut,filedir)
fprintf(fileOut, 'Run,Model,Location,Intensity,Direction,Error,Occlusions,Z-Movement\n');
directionFiles = dir(filedir);
for i = 3:length(directionFiles)
    Location = directionFiles(i).name;
    subdirname = [filedir '\' Location];
    printSingleLocation( subdirname,fileOut,Location)
end
end



function []  = printSingleLocation( subdirname,fileOut,Location)


directionFiles = dir(subdirname);
for i = 3:length(directionFiles)
    
    Direction = directionFiles(i).name;
    fileInNameTruth =  [subdirname '\' Direction '\CameraSpacetrackingNullOut.txt'];
    fileInNameDisp =  [subdirname '\' Direction '\trackingDisplacement.txt'];
    fileInNameExtra =  [subdirname '\' Direction '\trackingExtrapolation.txt'];
    fileInNameSpring =  [subdirname '\' Direction '\trackingSpring.txt'];
    fileINTruth  = fopen(fileInNameTruth,'r');
    fileInDisp   = fopen(fileInNameDisp,'r');
    fileINExtra  = fopen(fileInNameExtra,'r');
    fileINSpring = fopen(fileInNameSpring,'r');
    printSingleDirection(fileINTruth,fileInDisp,fileINExtra,fileINSpring,Direction,fileOut, Location)
    fclose(fileINTruth);
    fclose(fileInDisp);
    fclose(fileINExtra);
    fclose(fileINSpring);
    
    
end

end


function [] = printSingleDirection(fileINTruth,fileInDisp,fileINExtra,fileINSpring,Direction,fileOut, Location)
% disp, extra, spring, n
results = getErrors(fileINTruth,fileInDisp,fileINExtra,fileINSpring);


ResNorm = ([results(:,1) results(:,2) results(:,3) results(:,4)]./results(:,5));
ResNorm = [ResNorm results(:,5)];
str = '%i,%s,%s,%s,%s,%f,%i,%s\n';
[rows, cols] = size(ResNorm);

bucket = rows/3;
counter = 2;
for i = 2:rows
    for j = 1:(cols-1)
        
        if j ==1
            Model = 'Displacement';
        elseif j ==2
            Model = 'Extrapolation';
        elseif j == 3
            Model = 'Spring';
        else
            Model = 'Baseline';
        end
        
        if i <= bucket
            Intensity = 'Light';
        elseif i <= 2 * bucket
            Intensity = 'Medium';
        else
            Intensity = 'Strong';
        end
        
        if contains(Direction,'z')
            zMove = 'True';
        else
            zMove = 'False';
        end
        fprintf(fileOut,str,counter, Model, Location, Intensity, Direction, ResNorm(i,j),ResNorm(i,5), zMove);
        
    end
    if counter ==10
        counter =1;
    else
        counter = counter+1;
    end
end


end



function results = getErrors(fileINTruth,fileInDisp,fileINExtra,fileINSpring)
fileSize = linecount(fileINTruth);
results = zeros(fileSize,5);

FirstTruth  = frameReader(fileINTruth);
frewind(fileINTruth);


for i = 1:fileSize
    [disp, extra, spring, base, n] = getError(fileINTruth, fileInDisp,...
        fileINExtra, fileINSpring, FirstTruth);
    results(i,:) = [disp extra spring, base, n];
end
end


function [L] = frameReader(fileID)
line = fgetl(fileID);
L = jsondecode(line);
end


function occlusions = numOfOcclusions(Ltruth)
occlusions = 0;
for i = 1:numel(Ltruth.items)
    if ~ Ltruth.items(i).visible
        occlusions = occlusions+1;
    end
end
end



function [distDispo, distExtra,...
    distSpring, distBase, occlusions] = getError(fileINTruth, fileInDisp,...
    fileINExtra, fileINSpring, FirstTruth)
Ltruth  = frameReader(fileINTruth);
Ldisp   = frameReader(fileInDisp);
Lextra  = frameReader(fileINExtra);
Lspring = frameReader(fileINSpring);
distDispo  = 0;
distExtra  = 0;
distSpring = 0;
distBase = 0;
occlusions = numOfOcclusions(Ltruth);
if occlusions > 0
    for i = 1:numel(Ltruth.items)
        if ~ Ltruth.items(i).visible
            truth = Ltruth.items(i);
            disp = Ldisp.Items(i);
            extra = Lextra.Items(i);
            spring = Lspring.Items(i);
            base =  FirstTruth.items(i);
            
            truthVec = [truth.x, truth.y, truth.z];
            distDispo = distDispo + pdist([truthVec
                disp.x ,disp.y ,disp.z/1000 ],'euclidean');
            distExtra = distExtra + pdist([truthVec
                extra.x ,extra.y ,extra.z/1000 ],'euclidean');
            distSpring = distSpring + pdist([truthVec
                spring.x ,spring.y ,spring.z/1000 ],'euclidean');
            distBase = distBase + pdist([truthVec
                base.x ,base.y ,base.z ],'euclidean');
            
        end
    end
end
end

function n = linecount(fid)
n = 0;
tline = fgetl(fid);
while ischar(tline)
    tline = fgetl(fid);
    n = n+1;
end
frewind(fid)
end