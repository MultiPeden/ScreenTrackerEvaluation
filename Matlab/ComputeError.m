

clear;
fileInNameTruth  = 'data\\CameraSpacetrackingNullOut.txt';
fileInNameDisp   = 'data\\trackingDisplacement.txt';
fileInNameExtra  = 'data\\trackingExtrapolation.txt';
fileInNameSpring = 'data\\trackingSpring.txt';

fileINTruth  = fopen(fileInNameTruth,'r');
fileInDisp   = fopen(fileInNameDisp,'r');
fileINExtra  = fopen(fileInNameExtra,'r');
fileINSpring = fopen(fileInNameSpring,'r');

% disp, extra, spring, n
results = getErrors(fileINTruth,fileInDisp,fileINExtra,fileINSpring);
S = sum(results);

O = size(results);
bucket = O(1)/3;
B1 = sum(results(1:bucket,:));
resultsDisp = sqrt([B1(1) B1(2) B1(3)]/B1(4))

B2 = sum(results(bucket+1:bucket*2,:));
resultsExtra = sqrt([B2(1) B2(2) B2(3)]/B2(4))
B3 = sum(results(bucket*2+1:bucket*3,:));
resultsSpring = sqrt([B3(1) B3(2) B3(3)]/B3(4))

%resultsNormalized = [S(1) S(2) S(3)]/S(4);
%DisposError = sqrt(resultsNormalized(1))
%ExtrapError = sqrt(resultsNormalized(2))
%SpringError = sqrt(resultsNormalized(1))



fclose(fileINTruth);
fclose(fileInDisp);
fclose(fileINExtra);
fclose(fileINSpring);

%%



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
                disp.x ,disp.y ,disp.z/1000 ],'squaredeuclidean');
            distExtra = distExtra + pdist([truthVec
                extra.x ,extra.y ,extra.z/1000 ],'squaredeuclidean');
            distSpring = distSpring + pdist([truthVec
                spring.x ,spring.y ,spring.z/1000 ],'squaredeuclidean');
            
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