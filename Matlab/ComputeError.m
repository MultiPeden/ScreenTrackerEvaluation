

clear;
%fileInNameTruth  = 'data\\CameraSpacetrackingNullOut.txt';
%fileInNameDisp   = 'data\\trackingDisplacement.txt';
%fileInNameExtra  = 'data\\trackingExtrapolation.txt';
%fileInNameSpring = 'data\\trackingSpring.txt';

fileOut = fopen('Evaluation.csv','a');

filedir ='C:\Users\MultiPeden\Documents\GitHub\ScreenTrackerEvaluation\results\log';
printEvaluationToFile(fileOut,filedir)


fclose(fileOut);


%%


function []  = printEvaluationToFile(fileOut,filedir)
fprintf(fileOut, 'Run,Model,Location,Intensity,Direction,Value,Occlusions\n');
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


ResNorm = ([results(:,1) results(:,2) results(:,3)]./results(:,4));
ResNorm = [ResNorm results(:,4)];



str = '%i,%s,%s,%s,%s,%f, %i \n';


[rows, cols] = size(ResNorm);

bucket = rows/3;

for i = 1:rows
    for j = 1:(cols-1)

        if j ==1
            Model = 'Displacement';
        elseif j ==2
            Model = 'Extrapolation';
        else
            Model = 'Spring';
        end
        
        if i <= bucket
            Intensity = 'Light';
        elseif i <= 2 * bucket
            Intensity = 'Medium';
        else
            Intensity = 'Strong';
        end
          fprintf(fileOut,str,i, Model, Location, Intensity, Direction, ResNorm(i,j),ResNorm(i,4));
    end   
end


end



function results = getErrors(fileINTruth,fileInDisp,fileINExtra,fileINSpring)
fileSize = linecount(fileINTruth);
results = zeros(fileSize,4);
for i = 1:fileSize
    [disp, extra, spring, n] = getError(fileINTruth, fileInDisp,...
        fileINExtra, fileINSpring);
    results(i,:) = [disp extra spring n];    
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
    distSpring, occlusions] = getError(fileINTruth, fileInDisp,...
    fileINExtra, fileINSpring)
Ltruth  = frameReader(fileINTruth);
Ldisp   = frameReader(fileInDisp);
Lextra  = frameReader(fileINExtra);
Lspring = frameReader(fileINSpring);
distDispo  = 0;
distExtra  = 0;
distSpring = 0;
occlusions = numOfOcclusions(Ltruth);
if occlusions > 0
    for i = 1:numel(Ltruth.items)
        if ~ Ltruth.items(i).visible
            truth = Ltruth.items(i);
            disp = Ldisp.Items(i);
            extra = Lextra.Items(i);
            spring = Lspring.Items(i);
            
            truthVec = [truth.x, truth.y, truth.z];
            distDispo = distDispo + pdist([truthVec
                disp.x ,disp.y ,disp.z/1000 ],'euclidean');
            distExtra = distExtra + pdist([truthVec
                extra.x ,extra.y ,extra.z/1000 ],'euclidean');
            distSpring = distSpring + pdist([truthVec
                spring.x ,spring.y ,spring.z/1000 ],'euclidean');
            
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