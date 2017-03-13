function updatepreview(guiNd, varargin)
    % UPDATEPREVIEW Update the preview axes
    %   Detailed explanation goes here
    
    %% Parse the inputs.
    updatepreviewParser = inputParser;
    
    addRequired(updatepreviewParser, 'guiNd', @ishandle)
    addParameter(updatepreviewParser, 'Refresh', 0, @islogical)
    
    parse(updatepreviewParser, guiNd, varargin{:})
    
    %% Get the nd selection and stored nd data.
    popupNd = findobj(guiNd, 'Tag', 'popupNd');
    ndSelection = get(popupNd, 'Value');
    ndFiles = getappdata(popupNd, 'ndFiles');
    
    if isempty(ndFiles)
        return
    end % if
    
    % Get the data folder.
    ndFolder = getappdata(guiNd, 'ndFolder');

    % Get the nd data.
    ndData = ndFiles(ndSelection).Data;
    
    %% Get the axes and image object.
    hImage = findobj(guiNd, 'Type', 'Image');
    axesPreview = get(hImage, 'Parent');

    % Get the current axes limits so that we can preserve the view.
    axesXLim = get(axesPreview, 'XLim');
    axesYLim = get(axesPreview, 'YLim');
    
    %% Get the wavelength selections.
    checkWaves = flip(findobj(guiNd, '-regexp', 'Tag', 'checkWave\d'));
    if size(checkWaves, 1) > 1
        waveSelections = find(cell2mat(get(checkWaves, 'Value')));

    else
        waveSelections = find(get(checkWaves, 'Value'));
        
    end % if
    
    if isempty(waveSelections)
        set(hImage, 'CData', zeros(256, 256, 3, 'uint8'))
        return
    end % if
    
    %% Get the color component values.
    pushColors = flip(findobj(guiNd, '-regexp', 'Tag', 'pushColor\d'));
    pushColors = pushColors(waveSelections);
    
    if size(pushColors, 1) > 1
        waveColorComponents = cell2mat(get(pushColors, 'UserData'));
        waveColorComponents = bsxfun(@rdivide, ...
            waveColorComponents, sum(waveColorComponents, 1));
        waveColorComponents(isnan(waveColorComponents)) = 0;
    
    else
        waveColorComponents = get(pushColors, 'UserData');
    
    end % if
    
    %% Get the channel shifts.
    if size(checkWaves, 1) > 1
        editXShifts = flip(findobj(guiNd, '-regexp', 'Tag', 'editXWave\d'));
        xShifts = cellfun(@str2double, get(editXShifts, 'String'));

        editYShifts = flip(findobj(guiNd, '-regexp', 'Tag', 'editYWave\d'));
        yShifts = cellfun(@str2double, get(editYShifts, 'String'));

    else
        editXShifts = flip(findobj(guiNd, '-regexp', 'Tag', 'editXWave\d'));
        xShifts = str2double(get(editXShifts, 'String'));

        editYShifts = flip(findobj(guiNd, '-regexp', 'Tag', 'editYWave\d'));
        yShifts = str2double(get(editYShifts, 'String'));
        
    end % if
    
    waveShiftValues = [yShifts, xShifts];
    
    %% Get the scaling data and cached image data.
    normFactor = getappdata(guiNd, 'normFactor');
    climArray = getappdata(guiNd, 'climArray');
    cachedImageData = getappdata(axesPreview, 'cachedImageData');
    
    %% Display the selected image data in the preview axes.

    if updatepreviewParser.Results.Refresh
        % Get the time slider index selection.
        sliderTime = findobj(guiNd, 'Name', 'sliderTime');
        timeIdx = get(sliderTime, 'Value');
        
        % Get the z slider index selection.
        sliderZSlice = findobj(guiNd, 'Name', 'sliderZSlice');
        zIdx = get(sliderZSlice, 'Value');
        
        % Get the stage position selection.
        if size(ndData, 2) > 1
            listboxStage = findobj(guiNd, 'Tag', 'listboxStage');
            sIdx = get(listboxStage, 'Value');
            sIdx = sIdx(end);
            
        else
            sIdx = 1;
            
        end % if
        
        % Get the images and color factors.
        for w = 1:length(waveSelections)
            % Get the image list index for the wavelength that matches the time index.
            wTimes = ndData(sIdx).WaveTimes(waveSelections(w));
            if ~isnan(wTimes{1})
                imageListIdx = wTimes{1} == timeIdx;

            else
                imageListIdx = 1;
                
            end % if
            
            if ~any(imageListIdx)
                cachedImageData(w).Data = [];
                continue
            end % if

            % Get the wth image.
            if ndData(sIdx).WaveIsMultiZ(waveSelections(w))
                wImageData = double(imread(fullfile(...
                    ndFolder, ...
                    ndData(sIdx).WaveImages(waveSelections(w)).Images(imageListIdx).name), zIdx));
                
            else
                wImageData = double(imread(fullfile(...
                    ndFolder, ...
                    ndData(sIdx).WaveImages(waveSelections(w)).Images(imageListIdx).name)));
                
            end % if
            
            % Update the cached image data for the wavelength.
            cachedImageData(w).Data = wImageData;
            
            % Normalize.
            normFactor(waveSelections(w)) = max(wImageData(:));
            wImageDisplay = wImageData/normFactor(waveSelections(w));

            % Scale.
            wImageDisplay = mat2gray(wImageDisplay, climArray(waveSelections(w), :));

            % Shift the data.
            wImageDisplay = circshift(wImageDisplay, waveShiftValues(waveSelections(w), :));

            % Create the preview array.
            if ~(exist('previewImage', 'var') == 1)
                previewImage = zeros([size(wImageDisplay), 3]);
            end % if

            % Add the corresponding fraction of the wavelength image to the
            % preview array.
            wImageWeighted = bsxfun(@times, ...
                repmat(wImageDisplay, [1 1 3]), ...
                reshape(waveColorComponents(w, :), [1 1 3]));
            previewImage = previewImage + wImageWeighted;
        end % for w
        
        % Update the normalization values and cached data.
        setappdata(axesPreview, 'cachedImageData', cachedImageData)
        setappdata(guiNd, 'normFactor', normFactor)
    
    else
        % Used the cached images.
        for w = 1:length(waveSelections)
            if isempty(cachedImageData(w).Data)
                continue
            end % if

            % Get the cached wth image data.
            wImageData = cachedImageData(w).Data;

            % Normalize.
            wImageDisplay = wImageData/normFactor(waveSelections(w));

            % Scale.
            wImageDisplay = mat2gray(wImageDisplay, climArray(waveSelections(w), :));

            % Shift the data.
            wImageDisplay = circshift(wImageDisplay, waveShiftValues(waveSelections(w), :));

            % Create the preview array.
            if ~(exist('previewImage', 'var') == 1)
                previewImage = zeros([size(wImageDisplay), 3]);
            end % if

            % Add the corresponding fraction of the wavelength image to the
            % preview array.
            wImageWeighted = bsxfun(@times, ...
                repmat(wImageDisplay, [1 1 3]), ...
                reshape(waveColorComponents(w, :), [1 1 3]));
            previewImage = previewImage + wImageWeighted;
        end % for w
        
    end % if
    
    % Update the image object.
    if exist('previewImage', 'var')
        set(hImage, 'CData', previewImage)
        
    else
        set(hImage, 'CData', [])
        
    end % if
    
    axis(axesPreview, 'image')
    set(axesPreview, ...
        'XLim', axesXLim, ...
        'YLim', axesYLim)
end % updatepreview