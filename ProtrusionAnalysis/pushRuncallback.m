function pushRuncallback(~,~,checkNewFolder,popThresholdMenu,checkErode,guiPA,handles)
%pushRuncallback The 'RUN!' button essentialls runs the program to analyze the
%protrusions on a cell surface. Includes most of the error handling. R2015b
%
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017
    
    tic
    %% Load the structure parameters and assign variables
    structParameters = getappdata(guiPA,'structParameters');

    
    fileName = structParameters.inpathfile;
    inpathdir = strcat(structParameters.inpathdir,'\');
    outPath = strcat(structParameters.outpathdir,'\');
    newFolder = structParameters.newFolder;
    medMult = structParameters.medMult;
    erodeExtent = structParameters.erodeExtent;
    shrinkExtent = structParameters.shrinkExtent;
    timeRes = structParameters.timeRes;
    area = structParameters.area;
    sizeProtrusions = structParameters.sizeProtrusions;   
    
    
    %% Some initial error handling
    % Check to make sure there was some input
    if strcmp(fileName,'') == 1
        warndlg('No file was selected','No Files Found');
        return
    % Check to make sure an output directory exists
    elseif exist(outPath,'dir') ~= 7
        warndlg('Output path does not exist','No Folder Found');
        return
    % Check if new folder already exists. If it does, offer the user to
    % overwrite the files, or choose a new folder name. If it does not,
    % create the new folder in the output path directory.
    elseif get(checkNewFolder,'Value') == 1
        if exist(strcat(outPath,newFolder),'dir') == 7
            choice = questdlg('Warning','Analysis Directory','Overwrite','Cancel','Cancel');
            switch choice
                case 'Overwrite'
                    finaloutpath = strcat(outPath,newFolder,'\');
                case 'Cancel'
                    return
            end % switch
        else
            mkdir(outPath,newFolder);
            finaloutpath = strcat(outPath,newFolder,'\');
        end % if      
    else
        finaloutpath = strcat(outPath,'\');
    end % if
    
    %% Threshold and center of mass calculations
    structParameters.status = 'Status: Thresholding...';
    setappdata(guiPA,'structParameters',structParameters);
    set(handles.textStatus,'String',structParameters.status);
    pause(0.01)
    % Open the file for analysis
    fileStack = openTIFF(inpathdir,fileName);
    dimensions = size(fileStack);
    
    % Threshold based on inputs
    if get(popThresholdMenu,'Value') == 1
        BWStack = thresholdStack(fileStack,'median',medMult);
    elseif get(popThresholdMenu,'Value') == 2
        BWStack = thresholdStack(fileStack);
    end    
    % Write the threshold stack to directory
    writeTiff(BWStack,strcat(finaloutpath,'CoMThreshold_',fileName));
    
    % Function for adjusting the threshold
    CoMStack = preCoM(BWStack);
    
    structParameters.status = 'Status: Center of Mass...';
    setappdata(guiPA,'structParameters',structParameters);
    set(handles.textStatus,'String',structParameters.status);
    pause(0.01)
    
    % Calc the center of mass with erode function or not
    if get(checkErode,'Value') == 1
        se = strel('disk',erodeExtent);
        erodeStack = zeros(dimensions,'uint8');
        for ii = 1:dimensions(3)
            erodeStack(:,:,ii) = imerode(CoMStack(:,:,ii),se);
        end % for
        CoMStack = erodeStack;
        centerOfMass = calcCoM(erodeStack);
    else
        centerOfMass = calcCoM(CoMStack);
    end % if
    
    % Write the center of mass coordinates and stack to directory
    dlmwrite(strcat(finaloutpath,'centerOfMass.txt'),centerOfMass,'delimiter',',','newline','pc');
    writeTiff(CoMStack,strcat(finaloutpath,'CoMStack_',fileName));
    
    structParameters.status = 'Status: Stabilizing...';
    setappdata(guiPA,'structParameters',structParameters);
    set(handles.textStatus,'String',structParameters.status);
    pause(0.01)
    
    % Stabilize the image
    stableStack = stabilize(fileStack,centerOfMass);
    writeTiff(stableStack,strcat(finaloutpath,'Stable_',fileName));
    
    % Threshold the stable stack
    if get(popThresholdMenu,'Value') == 1
        stableThreshStack = thresholdStack(stableStack,'median',medMult);
    elseif get(popThresholdMenu,'Value') == 2
        stableThreshStack = thresholdStack(stableStack);
    end 
    % Write the stable threshold stack to directory
    writeTiff(stableThreshStack,strcat(finaloutpath,'StableThresh_',fileName));
    
    %% Masking and coverage stacks creation
    structParameters.status = 'Status: Masking...';
    setappdata(guiPA,'structParameters',structParameters);
    set(handles.textStatus,'String',structParameters.status);
    pause(0.01)
    % Create the mask and write the mask and the fillstack to directory
    [maskBinary,fillStack] = mask(stableThreshStack,guiPA);
    writeTiff(maskBinary,strcat(finaloutpath,'Mask_',fileName));
    writeTiff(fillStack,strcat(finaloutpath,'StableFill_',fileName));
    
    structParameters.status = 'Status: Coverages...';
    setappdata(guiPA,'structParameters',structParameters);
    set(handles.textStatus,'String',structParameters.status);
    pause(0.01)
    
    % calculate the instantaneous and cumulative coverage percentages
    [cropStack, backStack, threshStack, sumStack] = calculateCoverage(stableStack,maskBinary,fillStack);
    
    % Write the coverage stacks to directory
    writeTiff(cropStack,strcat(finaloutpath,'Crop_',fileName));
    writeTiff(backStack,strcat(finaloutpath,'Background_',fileName));
    writeTiff(threshStack,strcat(finaloutpath,'Thresh_',fileName));
    writeTiff(sumStack,strcat(finaloutpath,'Sum_',fileName));
    
    %% Protrusion sized measurements (boxes)
    % Walks a box across the image and collects the instensity through the
    % stack, if the box is completely within the area of the mask. 
    
    structParameters.status = 'Status: Dwell Time...';
    setappdata(guiPA,'structParameters',structParameters);
    set(handles.textStatus,'String',structParameters.status);
    pause(0.01)
    
    dims = size(stableStack); % new dimensions   
    for jj = 1:dims(2)-sizeProtrusions
        for kk = 1:dims(1)-sizeProtrusions
            for ii = 1:dims(3)
                if sum(sum(maskBinary(kk:kk+sizeProtrusions-1,jj:jj+sizeProtrusions-1))) == (sizeProtrusions^2)
                    sumStruct(kk,jj,ii) = sum(sum(threshStack(kk:kk+sizeProtrusions-1,jj:jj+sizeProtrusions-1,ii)));
                else
                    sumStruct(kk,jj,ii) = 0;
                end % if
            end % for
        end % for
    end % for
    
    % Finds the size of the sumStruct to create the list of projections
    dimSum = size(sumStruct);
    % Records the length of all possible protrusions
    for kk = 1:dimSum(1)
        for jj = 1:dimSum(2)
            for ii = 1:dimSum(3)
                if sumStruct(kk,jj,ii) >= area
                    count = 1;
                    while (ii + count) <= dimSum(3) && sumStruct(kk,jj,ii+count) >= area
                        count = count + 1;
                    end % while
                    pros(kk,jj,ii) = count;
                else
                    pros(kk,jj,ii) = 0;
                end % if
            end % for
        end % for
    end % for
    
    % Filters the protrusions, taking out sequential repeats.
    for kk = 1:dimSum(1)
        for jj = 1:dimSum(2)
            for ii = 1:dimSum(3)
                if pros(kk,jj,ii) == 0
                    proCount(kk,jj,ii) = 0;
                elseif (pros(kk,jj,ii) > 0  && (ii + 1 <= dimensions(3) && pros(kk,jj,ii+1) < pros(kk,jj,ii)))        
                    proCount(kk,jj,ii) = pros(kk,jj,ii);
                end % if
                if pros(kk,jj,ii) > 0  && (ii-1 > 0 && pros(kk,jj,ii) < pros(kk,jj,ii-1))
                    proCount(kk,jj,ii) = 0;
                end % if
            end % for
        end % for
    end % for
    
    % Counts the number of protrusions
    counts = 0;
    for kk = 1:dimSum(1)
        for jj = 1:dimSum(2)
            for ii = 1:dimSum(3)
                if proCount(kk,jj,ii) > 0
                    counts = counts + 1; 
                end % if
            end % for
        end % for
    end % for
    
    % Calculates the length and std dev of the protrusions
    avgLen = sum(sum(sum(proCount)))/counts;   
    stdLen = (sum(sum(proCount)))/counts;
    stdLen = std(stdLen);  
    
    
    
    %% Plotting / Data save
    
    structParameters.status = 'Status: Plotting / Saving...';
    setappdata(guiPA,'structParameters',structParameters);
    set(handles.textStatus,'String',structParameters.status);
    pause(0.01)
    
    totalPixels = sum(sum(maskBinary));

    % Save the coverages
    cumulativeCoverage = zeros(dims(3),3);
    for ii = 1:dimensions(3)
        cumulativeCoverage(ii,1) = ii*timeRes-timeRes;
        cumulativeCoverage(ii,2) = sum(sum(sumStack(:,:,ii)));
        cumulativeCoverage(ii,3) = sum(sum(sumStack(:,:,ii)))/totalPixels*100;
    end % for
    
    t75 = timeTo(cumulativeCoverage,75.0);
    t98 = timeTo(cumulativeCoverage,98.0);
    t100 = timeTo(cumulativeCoverage,100.0);
    
    instantCoverage = zeros(dims(3),3);
    for ii = 1:dims(3)
        instantCoverage(ii,1) = ii*timeRes-timeRes;
        instantCoverage(ii,2) = sum(sum(threshStack(:,:,ii)));
        instantCoverage(ii,3) = sum(sum(threshStack(:,:,ii)))/totalPixels*100;
    end % for
    
    averageInstantCoverage = mean(instantCoverage(:,3));
    
    dlmwrite(strcat(finaloutpath,'cumulativeCoverage.txt'),cumulativeCoverage,'delimiter',',','newline','pc');
    dlmwrite(strcat(finaloutpath,'instantCoverage.txt'),instantCoverage,'delimiter',',','newline','pc');
    
    fig2 = figure(2);
    plot(cumulativeCoverage(:,1),cumulativeCoverage(:,3),'r','LineWidth',1.5)
    xlabel('Time (seconds)');
    ylabel('Percent Coverage');
    axis tight
    ylim([30 100])
    h1 = legend(fileName,'location','southEast');
    set(h1,'interpreter','none');
    set(legend,'FontSize',16);
    saveas(fig2,strcat(finaloutpath,'cumulativeCoverage.png'));
    saveas(fig2,strcat(finaloutpath,'cumulativeCoverage.fig'));
    
    fig3 = figure(3);
    plot(instantCoverage(:,1),instantCoverage(:,3),'r','LineWidth',1.5)
    xlabel('Time (seconds)');
    ylabel('Percent Coverage at Timepoint');
    axis tight
    h2 = legend(fileName,'location','southEast');
    set(h2,'interpreter','none');
    set(legend,'FontSize',16);
    saveas(fig3,strcat(finaloutpath,'instantCoverage.png'));
    saveas(fig3,strcat(finaloutpath,'instantCoverage.fig'));
    
    runData = date;
    %% Analysis output file
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[FILE NAME]','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),fileName,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[ANALYSIS DATE]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),runData,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[THRESHOLD TYPE]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),get(popThresholdMenu,'Value'),'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[MEDIAN MULTIPLIER]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),medMult,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[ERODE EXTENT]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),erodeExtent,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[SHRINK EXTENT]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),shrinkExtent,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[TIME RESOLUTION]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),timeRes,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[AREA]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),area,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[PROTRUSION SIZE]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),sizeProtrusions,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[PROTRUSION DWELL TIME (S)]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),avgLen*timeRes,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[PROTRUSION DWELL TIME STD (S)]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),stdLen*timeRes,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[AVERAGE COVERAGE]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),averageInstantCoverage,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[T75]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),t75,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[T98]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),t98,'-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),'[T100]','-append','delimiter','','newline','pc');
    dlmwrite(strcat(finaloutpath,'AnalysisOutput.txt'),t100,'-append','delimiter','','newline','pc');
    
    
    structParameters.status = 'Status: Ready';
    setappdata(guiPA,'structParameters',structParameters);
    set(handles.textStatus,'String',structParameters.status);
    pause(0.01)
    
    msgbox('Done!','High Five!');
    
    toc

end % pushRuncallback

