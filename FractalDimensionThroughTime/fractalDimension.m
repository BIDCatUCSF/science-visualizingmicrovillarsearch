% Kyle Marchuk, PhD 
% Biological Imaging Development Center at UCSF
% August 2016 - Archived March 2017

% This script is used to determine the fractal dimension of the plane of
% interest of a Tcell (or any binary surface) through time. Uses .tif
% stack. Users following the Manuscript Pipeline will need to run the
% protrusionAnalysisGUI.m and will want to use the Stable Threshold
% output. This code has been verified with ImageJ's FracLac plugin.
%
% R2015b

tic

clear all
close all
clc

pathdir = 'C:...\'; % Final slash is necessary
fileName = 'Example.tif'; % Current only tested with .tif 

mkdir(pathdir,'FractalOutput'); % Creates an output directory
pathsave = strcat(pathdir,'FractalOutput\'); % String for saving

time = 2.25; % Time resolution useful for watching fractal dimension over time

minBoxLength = 3; % Pixels
maxBoxLength = 150; % Pixels

BoxLength = minBoxLength:1:maxBoxLength; % Creates the size range for box counting

% File info for the ROI
fileTif = strcat(pathdir,fileName);
fileInfo = imfinfo(fileTif);
xPix = fileInfo(1).Width;
yPix = fileInfo(1).Height;
nFrames = length(fileInfo);

xTime = (0:1:nFrames-1)*time; % Timepoints

% Load the file
fileStack = zeros(yPix,xPix,nFrames,'uint16');
for i=1:nFrames
    fileStack(:,:,i) = imread(fileTif,'Index',i,'Info',fileInfo);
end % for

% This finds the area through time in which to build the box frame
for ii = 1:nFrames
    count = 0;
    xList = [];
    yList = [];
    for kk = 1:yPix
        for jj = 1:xPix
            if fileStack(kk,jj,ii) > 0
                count = count + 1;
                xList(count,1) = jj;
                yList(count,1) = kk;
            end % if            
        end % for
    end % for
    xMin(ii,1) = int16(min(xList));
    xMax(ii,1) = int16(max(xList));
    yMin(ii,1) = int16(min(yList));
    yMax(ii,1) = int16(max(yList));
end % for

finalxMin = min(xMin);
finalyMin = min(yMin);
finalxMax = max(xMax);
finalyMax = max(yMax);

% If the file size needs to be padded with zeros to make room for the boxes
if (xPix - finalxMax < maxBoxLength || finalxMin < maxBoxLength) || (yPix - finalyMax <maxBoxLength || finalyMin < maxBoxLength)
    newyPix = 2*(ceil(finalyMax-finalyMin)/2)+(maxBoxLength*3);
    newxPix = 2*(ceil(finalxMax-finalxMin)/2)+(maxBoxLength*3);
    padStack = zeros(newyPix, newxPix,nFrames,'uint16');
else
    newyPix = yPix;
    newxPix = xPix;
    padStack = zeros(newyPix, newxPix,nFrames,'uint16');
end % if
% Create the new padded stack
for ii = 1:nFrames
    for kk = 1:yPix
        for jj = 1:xPix
            padStack(kk+((newyPix-yPix)/2),jj+(abs(newxPix-xPix)/2),ii) = fileStack(kk,jj,ii);
        end % for
    end % for
end % for

% Save a representative image of the expanded image for reference
fig1 = figure(1);
image(padStack(:,:,2),'CDataMapping','scaled');
colormap gray
axis equal
xlabel('Pixels','FontSize',14)
ylabel('Pixels','FontSize',14)
title('Expanded Image','Fontsize',14)
saveas(fig1,strcat(pathsave,'Padded.png'));
saveas(fig1,strcat(pathsave,'Padded.fig'));

% Find the new max and mins through time
for ii = 1:nFrames
    count = 0;
    padxList = [];
    padyList = [];
    for kk = 1:newyPix
        for jj = 1:newxPix
            if padStack(kk,jj,ii) > 0
                count = count + 1;
                padxList(count,1) = jj;
                padyList(count,1) = kk;
            end % if            
        end % for
    end % for
    padxMin(ii,1) = int16(min(padxList));
    padxMax(ii,1) = int16(max(padxList));
    padyMin(ii,1) = int16(min(padyList));
    padyMax(ii,1) = int16(max(padyList));
end % for
finalpadxMin = min(padxMin);
finalpadyMin = min(padyMin);
finalpadxMax = max(padxMax);
finalpadyMax = max(padyMax);

% For each frame and each box size find the fewest boxes needed to capture
% all the thresholded intensity. This is accomplished by shifting the box
% frame origin by the size of the box in the 2 dimensions.
for ii = 1:nFrames
    shiftBox = [];
    for rr = 1:length(BoxLength)
        for qq = 0:BoxLength(rr) - 1
            for ww = 0:BoxLength(rr) - 1
                box = 0;
                boxCount = 0;
                while (box * BoxLength(rr) < (newyPix - finalpadyMin - BoxLength(rr)))    
                    yLoc = (finalpadyMin-qq)+(box*BoxLength(rr));
                    xbox = 0;
                    while xbox * BoxLength(rr) < newxPix - finalpadxMin - BoxLength(rr)        
                        xLoc = (finalpadxMin-ww)+(xbox*BoxLength(rr));        
                        temp = sum(sum(padStack(yLoc:yLoc+BoxLength(rr)-1,xLoc:xLoc+BoxLength(rr)-1,ii)));
                            if temp > 0
                                boxCount = boxCount + 1;
                            end % if
                        xbox = xbox + 1;
                    end
                    box = box + 1;
                end % while
                if boxCount > 0 
                    shiftBox(qq+1,ww+1,rr) = boxCount;
                else
                    shiftBox(qq+1,ww+1,rr) = inf;
                end
            end % for    
        end % for
        fewestBoxes(ii,rr) = min(min(shiftBox(:,:,rr)));
    end % for
    
    disp(ii)
end % for
dlmwrite(strcat(pathsave,'fewestBoxes.txt'),fewestBoxes,'delimiter','\t','newline','pc');

% Fit the box counts to the fractal dimension equation
for tt = 1:nFrames
    p(tt,:) = polyfit(log10(BoxLength),log10(fewestBoxes(tt,:)),1);
    fracD(tt,1) = p(tt,1);
end % for

dlmwrite(strcat(pathsave,'FracDimensions.txt'),abs(fracD),'delimiter','\t','newline','pc');

% Calculate the average fractal dimension through time
mFracD = abs(mean(fracD));

% Plot the Fractal dimension through time
fig2 = figure(2);
plot(xTime,abs(fracD),'r-d','LineWidth',2)
% ylim([1.65 1.75])
xlabel('Time (s)','FontSize',14)
ylabel('Fractal Dimension','FontSize',14)
title(fileName,'interpreter','none','FontSize',14)
saveas(fig2,strcat(pathsave,'FracVTime.png'));
saveas(fig2,strcat(pathsave,'FracVTime.fig'));

% Calculate the line of best fit
fit = linspace(minBoxLength,maxBoxLength,100);
for ii = 1:nFrames
    yArr(ii,:) = 10^p(ii,2)*fit.^p(ii,1);
end
dlmwrite(strcat(pathsave,'fitText.txt'),yArr,'delimiter','\t','newline','pc');

% Plot each timepoint for the record. Comment out as desired.
for ii = 1:nFrames
    fig3 = figure(3);
%    ylim([0 700])
    scatter(log10(BoxLength),log10(fewestBoxes(ii,:)))
    hold on
    plot(log10(fit),log10(yArr(ii,:)))
    
    xlabel('log_1_0 Box Length','FontSize',14)
    ylabel('log_1_0 Number of Boxes','FontSize',14)
    title(fileName,'interpreter','none','FontSize',14)
    legend('Data','fit','location','NorthEast')
    saveas(fig3,strcat(pathsave,int2str(ii),'_TimeLog.png'));
%     saveas(fig3,strcat(pathsave,int2str(ii),'_TimeLog.fig'));
    close all
% 
    fig4 = figure(4);
    ylim([0 3])
    scatter(BoxLength,fewestBoxes(ii,:))
    hold on
    plot(fit,yArr(ii,:))
    
    xlabel('Box Length','FontSize',14)
    ylabel('Number of Boxes','FontSize',14)
    title(fileName,'interpreter','none','FontSize',14)
    legend('Data','fit','location','NorthEast')
    saveas(fig4,strcat(pathsave,int2str(ii),'_Time.png'));
%     saveas(fig4,strcat(pathsave,int2str(ii),'_Time.fig'));
    close all
    disp(ii)
end

% Append the data to a summary text file. Comment out as desired.
fid = fopen('C:...\FileName.txt','at');
fmt = '%s\t%d\r\n';
fprintf(fid,fmt,fileName,mFracD);
fclose(fid);

toc
