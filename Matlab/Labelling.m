
clear;
fileInName = 'data\\trackingNull.txt';
colorfileInName = 'data\\trackingcolor.txt';
fileOutName = 'data\\trackingNullOut.txt';
imageFileFormat = 'data\\test%d.png';
colorimageFileFormat = 'data\\test%dcolor.png';
numOfCols = 9;

RunLabelling(fileInName, colorfileInName, fileOutName, imageFileFormat,colorimageFileFormat, numOfCols)





%% functions

function RunLabelling(fileInName,colorfileInName, fileOutName, imageFileFormat,colorimageFileFormat, numOfCols)
fileIN = fopen(fileInName,'r');
fileINcolor = fopen(colorfileInName,'r');

fileOut = fopen(fileOutName,'w');
frameCounter = 0;
figIR = figure('units','normalized','outerposition',[0 0 1 1]);
figcolor = figure('units','normalized','outerposition',[0 0 1 1]);


while ~feof(fileIN)
    L = frameReader(fileIN);
    Lcolor = frameReader(fileINcolor);
    pointsMissing = arePointsMissing(L);
    if pointsMissing
        filename = sprintf(imageFileFormat, frameCounter);
        colorfilename = sprintf(colorimageFileFormat, frameCounter);
        A = imread(filename);
        B = imread(colorfilename);
        figure(figcolor)
        image(B);
               drawPoints(Lcolor, 'b');
        
        figure(figIR)
        
 
        
        imshow(A, hot,'InitialMagnification','fit');
        
        missing   = drawPoints(L, '');
        L = labelRest(missing, numOfCols, L, frameCounter);
    end
    
    text = jsonencode(L);
    fprintf(fileOut, text);
    fprintf(fileOut,'\n');
    frameCounter = frameCounter + 1;
end

fclose(fileIN);
fclose(fileOut);
close all;
end


function pointsMissing = arePointsMissing(L)
pointsMissing =0;
for i = 1:numel(L.Items)

 
    if ~ L.Items(i).visible
        pointsMissing = 1;
        break;
    end
    
end
end


function [L] = frameReader(fileID)
line = fgetl(fileID);
L = jsondecode(line);
end


function [] = drawDot(x,y, col, index, size)
if strcmp(col,'p')
    FaceColor = [0 .5 .5];
else
    FaceColor = [.5 .5 .5];
end
if size == 'b'
    pos = [x-15 y-15 30 30];
else
    pos = [x-5 y-5 10 10];
end
rectangle('Position',pos,'FaceColor', FaceColor,'Curvature',[1 1])
text('position',[x+ .5 y],'fontsize',10,'color','w','string',int2str(index), 'HorizontalAlignment', 'center' );

end

function missing = drawPoints(L, size)

missing = [];
for i = 1:numel(L.Items)
    id = i-1;
    x = L.Items(i).x;
    y = L.Items(i).y;
    if ~isequal(x , [])
        drawDot(x,y, 'p' ,id, size)
    else
        missing = vertcat(missing, id);
    end
end
end



function L = labelRest(missing, numOfCols, L, frameNr)
prompt = 'Enter depth:';
titleFormat = 'Label missing point: %d';

dims = [1 50];
%input  = zeros(length(missing),4);


for i = 1:numel(missing)
    
    
    id = missing(i);
    
    neighboursString = allNeighbourStr(id, numOfCols, L);
    prompText = [neighboursString newline newline prompt];
    
    title(sprintf("Frame %d: Click on marker %d's position", frameNr,id));
    [x, y]=ginput(1);
    titleText = sprintf(titleFormat,id);
    %  titleText = strcat(titleText, newline  , 'hej')
    
    answer = inputdlg(prompText,titleText,dims);
    z = str2double(answer{1,1});
    
    idPlus = id +1;
    L.Items(idPlus).x = x;
    L.Items(idPlus).y = y;
    
    L.Items(idPlus).z = z;
    drawDot(x,y, 'n', id,'');
end
end

function str = allNeighbourStr(id, numOfCols, L)

n = length(L.Items);
idModCols = mod(id,numOfCols);
found =0;
nID = canGoNorth(id, numOfCols);
zAccumulated = 0;
[strN, z, found] =  neighbourStr(nID,'North', L, found);
zAccumulated = zAccumulated + z;
nID = canGoEast(id, n, numOfCols, idModCols);
[strE, z, found] = neighbourStr(nID,'East', L, found);
zAccumulated = zAccumulated + z;
nID = canGoSouth(id, n, numOfCols);
[strS, z, found] = neighbourStr(nID,'South', L, found);
zAccumulated = zAccumulated + z;
nID = canGoWest(id,numOfCols, idModCols);
[strW, z, found] = neighbourStr(nID,'West', L, found);
zAccumulated = zAccumulated + z;
zAVG = double(zAccumulated) / double(found);

zAVGstr = ['Average: = ' num2str(zAVG) ' mm'];

str = [strN newline strE newline strS newline strW newline zAVGstr];
end

function [str, z, found] = neighbourStr(index, dir, L, found)
missingFormat = '%s Id: %d Z = %g mm';
missingFormatNA = '%s - Not Available';
if ~(index == -1 || L.Items(index+1).visible==0 )
    z = L.Items(index+1).z;
    str = sprintf(missingFormat,dir, index , z);
    found = found + 1;
else
    z = 0;
    str = sprintf(missingFormatNA,dir);
end
end


function index  = canGoNorth(id, numOfCols)
index = id - numOfCols;
if index < 0
    index = -1;
end
end

function index  = canGoSouth(id, n, numOfCols)
index = id + numOfCols;
if index > n
    index = -1;
end
end

function index  = canGoEast(id, n, numOfCols, idModCols)
index = id + 1;
if (index > n ) || ( idModCols ==0 )
    index = -1;
end
end

function index  = canGoWest(id,numOfCols, idModCols)
index = id - 1;
if (index < 0 ) || ( idModCols == numOfCols - 1 )
    index = -1;
end
end


