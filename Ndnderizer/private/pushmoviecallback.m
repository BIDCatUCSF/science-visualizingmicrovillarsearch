function pushmoviecallback(~, ~, guiNd)
    % PUSHMOVIECALLBACK Create a movie from selected .nd data
    %
    %
    %
    %   ©2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/

    
    %% Get the folder.
    ndFolder = getappdata(guiNd, 'ndFolder');
    
    %% Get the .nd set information.
    popupNd = findobj(guiNd, 'Tag', 'popupNd');
    ndFiles = getappdata(popupNd, 'ndFiles');
    ndSelection = get(popupNd, 'Value');
    ndData = ndFiles(ndSelection).Data;
    ndBase = strrep(ndFiles(ndSelection).name, '.nd', '');
    
    %% Get the stage position information.
    % Get the stage selections.
    listboxStage = findobj(guiNd, 'Tag', 'listboxStage');
    stageSelections = get(listboxStage, 'Value');
    sIdx = stageSelections(1);
    
    %% Find the selected wavelengths.
    waveNames = ndData.WaveName;
    
    % Construct the wavelength string file identifiers.
    waveStrs = ndData.WaveIDString;

    % Get the wavelength selections.
    checkWaves = flip(findobj(guiNd, '-regexp', 'Tag', 'checkWave\d'));
    waveSelections = logical(cell2mat(get(checkWaves, 'Value')));
        
    % Get the wavelength strings to process.
    waveNameImportList = waveNames(waveSelections);
    waveStrImportList = waveStrs(waveSelections);
    
    %% Get the z information for the wavelength set.
    % Find the wavelengths with multiple z data.
    if any(ndData.WaveIsMultiZ)
        zSize = ndData.ZCount(1); % z-size is per data set--just need the first wave z-size.
        isDoZ = ndData.WaveIsMultiZ(waveSelections);

    else
        zSize = 1;
        isDoZ = zeros(size(waveSelections));

    end % if
        
    %% Get the channel shifts.
    editXShifts = flip(findobj(guiNd, '-regexp', 'Tag', 'editXWave\d'));
    xShifts = cellfun(@str2double, get(editXShifts, 'String'));
    
    editYShifts = flip(findobj(guiNd, '-regexp', 'Tag', 'editYWave\d'));
    yShifts = cellfun(@str2double, get(editYShifts, 'String'));
    
    waveShiftValues = [xShifts, yShifts];
    waveShiftFlag = sum(waveShiftValues, 2) > 0;
    
    %% Get the time points for wavelengths acquisitions.
    % We need this to make sure we get all the time stamps.
    wavePointsCollected = cellfun(@length, ndData.WaveTimes);

    %% Get the clim array to scale the image display ranges to match the preview.
    climArray = getappdata(guiNd, 'climArray');
    climArray = climArray(waveSelections, :);
    
    %% Prepare the status bar and counting index.
    hStatus = statusbar(guiNd, ['Exporting ' ndBase]);
    hStatus.CornerGrip.setVisible(false)

    hStatus.ProgressBar.setForeground(java.awt.Color.black)
    hStatus.ProgressBar.setString('')
    hStatus.ProgressBar.setStringPainted(true)
    hStatus.ProgressBar.setValue(0)
    hStatus.ProgressBar.setVisible(true)
        
    % Initialize a variable and timer to record the transfer progress. Increment
    % every time we place an image into the Imaris data set.
    ticTransfer = tic;
    transferIdx = 0;
        
    %% Read the images and transfer to Imaris:
    for s = 1:length(stageStrImportList)
        % Update the progress bar with the stage name.
        hStatus.setText(...
            ['Exporting ' ndBase ...
            ' | Postion ' num2str(stageSelections(s)) ' (' stageNameImportList{s} ')'])
        
        %% Get the stage position images.
        waveImages = ndData(s).WaveImages;
        
        % Calculate the number of images to transfer.
        waveImageCounts = arrayfun(@(s)length(s.Images), waveImages);
        transferCount = sum(waveImageCounts(waveSelections));
        hStatus.ProgressBar.setMaximum(transferCount)
        
        % Get the file format.
        imageExtension = cell2mat(lower(...
            regexp(waveImages(1).Images(1).name, '(.TIF)|(.tif)|(.STK)|(.stk)$', ...
            'Match', 'ignorecase')));
        
        %% Calculate the actual number of time points from the image lists.
        tSize = max(wavePointsCollected);
        
        %% Read the time stamps.
        timeStamps = cell(tSize, 1);
        
        % Get the first wavelength that doesn't have special time point
        % acquistion.
        firstFullTimeWave = find(wavePointsCollected == max(wavePointsCollected), 1, 'first');
        
        % Disable tag processing div by zero warning.
        warning off MATLAB:imagesci:tifftagsread:badTagValueDivisionByZero

        for t = 1:tSize
            imageInfo = imfinfo(fullfile(...
                ndFolder, waveImages(firstFullTimeWave).Images(t).name));
            
            timeStamps{t} = imageInfo.DateTime;
        end % for t
                
        %% Get the date portion of the stamps and format for Imaris.
        imarisDates = regexp(timeStamps, '^\d{8}|\d{4}:\d{2}:\d{2}', 'Match');
        imarisDates = cellfun(@cell2mat, imarisDates, 'UniformOutput', 0);
        imarisDates = regexprep(imarisDates, ...
            '(\d{4})(\d{2})(\d{2})|(\d{4}):(\d{2}):(\d{2})', '$1-$2-$3');
        
        %% Get the time portion of the stamps.
        imarisTimes = regexp(timeStamps, ...
            '\d{2}:\d{2}:\d{2}$|\d{2}:\d{2}:\d{2}\.\d{2,}$', 'Match');
        imarisTimes = cellfun(@cell2mat, imarisTimes, 'UniformOutput', 0);
        
        %% Pad two digit millisecond values with a leading zero.
        % No really, Metamorph writes xy milliseconds as .xy seconds...
        imarisTimes = regexprep(imarisTimes, '(\.)(\d{2})$', '$10$2');
        
        %% Create data set.
        xSize = imageInfo(1).Width;
        ySize = imageInfo(1).Height;
        
        xDataSet = xImarisApp.GetFactory.CreateDataSet;
        java.lang.System.gc()
        
        %% Fill the data set according to the data type.
        % Get the images' bit depth.
        mBitString = ['uint' num2str(imageInfo(1).BitDepth)];
        
        switch mBitString
            
            case 'uint8'
                %% Create the data set.
                xDataSet.Create(Imaris.tType.eTypeUInt8, ...
                    xSize, ySize, zSize, length(waveNameImportList), tSize)

                %% Transfer all the wavelengths into the data set.
                for w = 1:length(waveStrImportList)
                    if waveImages(w).DoZ
                        wStack = zeros(xSize, ySize, zSize, mBitString);

                        switch imageExtension
                            
                            case '.tif'
                                for t = ndData.WaveTimes{w}'
                                    for z = 1:zSize
                                        wStack(:, :, z) = rot90(imread(fullfile(...
                                            ndFolder, waveImages(w).Images(t).name), z), 3);
                                    end % for z

                                    % Shift the data if requested.
                                    if waveShiftFlag(w)
                                        wStack = circshift(wStack, waveShiftValues(w, :));
                                    end % if

                                    xDataSet.SetDataVolumeBytes(wStack, ...
                                            w - 1, t - 1)

                                    transferIdx = transferIdx + 1;
                                    hStatus.ProgressBar.setValue(transferIdx)
                                end % for t

                            case '.stk'
                                for t = ndData.WaveTimes{w}'
                                    for z = 1:zSize
                                        wSlice = tiffread(fullfile(...
                                            ndFolder, waveImages(w).Images(t).name), z);
                                        wStack(:, :, z) = rot90(wSlice.data, 3);
                                    end % for z
                                    
                                    % Shift the data if requested.
                                    if waveShiftFlag(w)
                                        wStack = circshift(wStack, waveShiftValues(w, :));
                                    end % if

                                    xDataSet.SetDataVolumeBytes(wStack, ...
                                            w - 1, t - 1)

                                    transferIdx = transferIdx + 1;
                                    hStatus.ProgressBar.setValue(transferIdx)
                                end % for t
                                
                        end % switch

                    else
                        % Check whether to expand the single z to all
                        % slices.
                        toggleSingleZExpand = findobj(guiNd, 'Tag', 'toggleSingleZExpand');
                        
                        % Read the slice and expand, or add the single z to
                        % the bottom slice.
                        if get(toggleSingleZExpand, 'Value')
                            for t = ndData.WaveTimes{w}'
                                wSlice = rot90(imread(fullfile(...
                                    ndFolder, waveImages(w).Images(t).name)), 3);
                                
                                % Expand the slice to all z planes.
                                wStack = repmat(wSlice, [1 1 zSize]);
                                
                                % Shift the data if requested.
                                if waveShiftFlag(w)
                                    wStack = circshift(wStack, waveShiftValues(w, :));
                                end % if
                                
                                xDataSet.SetDataVolumeBytes(wStack, w - 1, t - 1)
                                
                                transferIdx = transferIdx + 1;
                                hStatus.ProgressBar.setValue(transferIdx)
                            end % for t
                            
                        else
                            % Read the image in the tiff.
                            for t = ndData.WaveTimes{w}'
                                wSlice = rot90(imread(fullfile(...
                                    ndFolder, waveImages(w).Images(t).name)), 3);
                                
                                % Shift the data if requested.
                                if waveShiftFlag(w)
                                    wSlice = circshift(wSlice, waveShiftValues(w, :));
                                end % if
                                
                                xDataSet.SetDataSliceBytes(wSlice, 0, w - 1, t - 1)
                                
                                transferIdx = transferIdx + 1;
                                hStatus.ProgressBar.setValue(transferIdx)
                            end % for t
                            
                        end % if

                    end % if
                    
                    xDataSet.SetChannelName(w - 1, waveNameImportList(w))
                    
                    %% Set the channel color.
                    pushColor = findobj(guiNd, '-regexp', 'Tag', ['pushColor' num2str(w)]);
                    setColor = get(pushColor, 'UserData');
                    
                    % Set the color in the data set.
                    xDataSet.SetChannelColorRGBA(w - 1, setColor)
                    %% Set the channel display range to match the preview axes.
                    xDataSet.SetChannelRange(w - 1, climArray(w, 1)*255, climArray(w, 2)*255)
                    
                end % for w
                
            case 'uint16'
                %% Create the data set.
                xDataSet.Create(Imaris.tType.eTypeUInt16, ...
                    xSize, ySize, zSize, length(waveNameImportList), tSize)
                
                %% Transfer all the wavelengths into the data set.
                for w = 1:length(waveStrImportList)
                    if isDoZ(w)
                        wStack = zeros(xSize, ySize, zSize, mBitString);

                        switch imageExtension
                            
                            case '.tif'
                                for t = ndData.WaveTimes{w}'
                                    for z = 1:zSize
                                        wStack(:, :, z) = rot90(imread(fullfile(...
                                            ndFolder, waveImages(w).Images(t).name), z), 3);
                                    end % for z

                                    % Shift the data if requested.
                                    if waveShiftFlag(w)
                                        wStack = circshift(wStack, waveShiftValues(w, :));
                                    end % if

                                    xDataSet.SetDataVolumeShorts(wStack, ...
                                            w - 1, t - 1)

                                    transferIdx = transferIdx + 1;
                                    hStatus.ProgressBar.setValue(transferIdx)
                                end % for t

                            case '.stk'
                                for t = ndData.WaveTimes{w}'
                                    for z = 1:zSize
                                        wSlice = tiffread(fullfile(...
                                            ndFolder, waveImages(w).Images(t).name), z);
                                        wStack(:, :, z) = rot90(wSlice.data, 3);
                                    end % for z
                                    
                                    % Shift the data if requested.
                                    if waveShiftFlag(w)
                                        wStack = circshift(wStack, waveShiftValues(w, :));
                                    end % if

                                    xDataSet.SetDataVolumeShorts(wStack, ...
                                            w - 1, t - 1)

                                    transferIdx = transferIdx + 1;
                                    hStatus.ProgressBar.setValue(transferIdx)
                                end % for t
                                
                        end % switch

                    else
                        % Check whether to expand the single z to all
                        % slices.
                        toggleSingleZExpand = findobj(guiNd, 'Tag', 'toggleSingleZExpand');
                        
                        if get(toggleSingleZExpand, 'Value')
                            for t = ndData.WaveTimes{w}'
                                wSlice = rot90(imread(fullfile(...
                                    ndFolder, waveImages(w).Images(t).name)), 3);
                                
                                % Expand the slice to all z planes.
                                wStack = repmat(wSlice, [1 1 zSize]);
                                                            
                                % Shift the data if requested.
                                if waveShiftFlag(w)
                                    wStack = circshift(wStack, waveShiftValues(w, :));
                                end % if

                                xDataSet.SetDataVolumeShorts(wStack, ...
                                        w - 1, t - 1)
                                
                                transferIdx = transferIdx + 1;
                                hStatus.ProgressBar.setValue(transferIdx)
                            end % for t
                            
                        else % Single z.
                            for t = ndData.WaveTimes{w}'
                                wSlice = rot90(imread(fullfile(...
                                    ndFolder, waveImages(w).Images(t).name)), 3);
                                
                                % Shift the data if requested.
                                if waveShiftFlag(w)
                                    wSlice = circshift(wSlice, waveShiftValues(w, :));
                                end % if

                                xDataSet.SetDataSliceShorts(wSlice, 0, w - 1, t - 1)
                                
                                transferIdx = transferIdx + 1;
                                hStatus.ProgressBar.setValue(transferIdx)
                            end % for t
                            
                        end % if

                    end % if
                    
                    xDataSet.SetChannelName(w - 1, waveNameImportList(w))
                    
                    %% Set the channel color.
                    pushColor = findobj(guiNd, '-regexp', 'Tag', ['pushColor' num2str(w)]);
                    setColor = rgbtripleto24bit(get(pushColor, 'UserData'));
                    
                    % Set the color in the data set.
                    xDataSet.SetChannelColorRGBA(w - 1, setColor)
                    
                    %% Set the channel display range to match the preview axes.
                    xDataSet.SetChannelRange(w - 1, climArray(w, 1)*65535, climArray(w, 2)*65535)
                    
                end % for w
                
        end % switch
        
        %% Set the data set and meta data.
        xImarisApp.SetDataSet(xDataSet)

        % Set the time stamps:
        for t = 1:tSize
            xDataSet.SetTimePoint(t - 1, [imarisDates{t} ' ' imarisTimes{t}])
        end % for t    

        % Set the z calibration:
        zStep = ndData(1).ZStepSize;
        
        % If their is no step size, use a default unit.
        if isempty(zStep)
            zStep = 1;
        end
            
        % Set the z size by setting the min and max.
        xDataSet.SetExtendMinZ(0);
        xDataSet.SetExtendMaxZ(zStep*zSize)
        
        % Try to find the x calibration data:
        xCalLine = regexp(imageInfo(1).ImageDescription, ...
                '<prop id="spatial-calibration-x" type="float" value="(\d{1,}.\d{1,}|\d)">', 'Match');
        xCalString = regexp(xCalLine{:}, '(\d{1,}.\d{1,}|\d)', 'Match');
        
        % If the calibration data was written, apply it to the Imaris data
        % set.
        if ~isempty(xCalString)
            xStep = str2double(xCalString);

            xDataSet.SetExtendMinX(0);
            xDataSet.SetExtendMaxX(xStep*xSize)

            % Now find the y calibration data:
            yCalLine = regexp(imageInfo(1).ImageDescription, ...
                    '<prop id="spatial-calibration-y" type="float" value="(\d{1,}.\d{1,}|\d)">', 'Match');
            yCalString = regexp(yCalLine{:}, '(\d{1,}.\d{1,}|\d)', 'Match');
            
            yStep = str2double(yCalString);

            xDataSet.SetExtendMinY(0);
            xDataSet.SetExtendMaxY(yStep*ySize)
        end % if
        
        %% Store the stage position in the meta data.
        xStageLine = regexp(imageInfo(1).ImageDescription, ...
            '<prop id="stage-position-x" type="float" value="(\-|)(\d|\d{1,}.\d{1,})">', 'Match');

        if ~isempty(xStageLine)
            xStageString = regexp(xStageLine{:}, '(\-|)(\d{1,}.\d{1,}|\d)', 'Match'); 
            xStage = xStageString{1};
            
            % Now find the y stage position property:
            yStageLine = regexp(imageInfo(1).ImageDescription, ...
                '<prop id="stage-position-y" type="float" value="(\-|)(\d|\d{1,}.\d{1,})">', 'Match');
        
            yStageString = regexp(yStageLine{:}, '(\-|)(\d{1,}.\d{1,}|\d)', 'Match'); 
            yStage = yStageString{1};
            
        else
            xStage = 'NA';
            yStage = 'NA';
            
        end % if
                
        xDataSet.SetParameter('Image', 'Description', ...
            ['Stage Position X: ' xStage ' Stage Position Y: ' yStage])
        
        %% Save the file.
        if ~isempty(stageNameImportList{s})
            xImarisApp.FileSave(fullfile(...
                ndFolder, [ndBase ' - ' stageNameImportList{s} '.ims']), '');
            
        else
            xImarisApp.FileSave(fullfile(...
                ndFolder, [ndBase '.ims']), '');
            
        end % if
        
        %% Update the time remaining.
        tocTransfer = toc(ticTransfer);
        transferAvg = tocTransfer/s;
        
        remainingTime = transferAvg*(length(stageStrImportList) - s)/86400;
        remainingTimeString = datestr(remainingTime, 'HH:MM');
        splitString = regexp(remainingTimeString, ':', 'Split');
        if strcmp(splitString{1}, '00') && strcmp(splitString{2}, '00')
            formattedString = 'Less than 1 min remaining';
            
        else
            formattedString = [splitString{1},  ' hr ' splitString{2} ' min remaining'];
            
        end % if
        
        
        % Update the progress bar.
        hStatus.ProgressBar.setString(formattedString)            
    end % for s
    
    %% Disable tag processing div by zero warning.
    warning on MATLAB:imagesci:tifftagsread:badTagValueDivisionByZero
    
    %% Cleanup the statusbar.
    dataFolderStatusString = ['Current folder: ' strrep(ndFolder, '\', '\\')];
    hStatus.setText(dataFolderStatusString)
    hStatus.ProgressBar.setString('')
    hStatus.ProgressBar.setValue(0);
    hStatus.ProgressBar.setVisible(false)    
end % pushmoviecallback
