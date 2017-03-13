function pushcontourcallback(~, ~, editMaskTime, axesPreview, guiContour)
    % PUSHCONTOURCALLBACK Contour the current time point
    %   Detailed explanation goes here
    
    %% If the mask isn't set, return.
    rgnMask = getappdata(axesPreview, 'rgnMask');
    if isempty(rgnMask);
        return
    end % if
    
    %% Setup the status bar.
    hStatus = statusbar(guiContour, 'Contouring images');
    
    %% Get the stored contours.
    contourHandleList = getappdata(axesPreview, 'contourHandleList');
    
    %% Get the time point to contour and upate the preview if needed.
    tIdx = str2double(get(editMaskTime, 'String'));
    editTime = findobj(guiContour, 'Tag', 'editTime');
    
    if tIdx ~= str2double(get(editTime, 'String'))
        sliderTime = findobj(guiContour, 'Name', 'sliderTime');
        set(sliderTime, 'Value', tIdx)
        set(editTime, 'String', tIdx)
        updatepreview(editMaskTime, axesPreview, guiContour)
    end % if
    
    %% Initialize the mask and setup cropping if active.
    toggleCrop = findobj(guiContour, 'Tag', 'toggleCrop');
    if get(toggleCrop, 'Value')
        % Get the crop region.
        rgnCrop = getappdata(axesPreview, 'rgnCrop');
        cropPos = floor(rgnCrop.getPosition);
        
        % Convert the ROI to index ranges.
        xLimits = cropPos(1) + 1:cropPos(1) + 1 + cropPos(3);
        yLimits = cropPos(2) + 1:cropPos(2) + 1 + cropPos(4);
        
        % Initialize the cropped mask.
        phiIn = rgnMask.createMask;
        phiIn = phiIn(yLimits, xLimits);
        phiIn = ac_reinit(phiIn - 0.5);
        
    else
        % Initialize the mask without cropping.
        phiIn = rgnMask.createMask;
        phiIn = ac_reinit(phiIn - 0.5);
                
        % Create the dafault (full) index range.
        xLimits = 1:size(phiIn, 2);
        yLimits = 1:size(phiIn, 1);
        
    end % if
        
    %% Get the input data.
    previewData = getappdata(axesPreview, 'previewData');
    xSize = size(previewData, 2);
    ySize = size(previewData, 1);
    
    %% Run the active contour algorithm and draw the contour on the image.
    % Get the contour settings.
    editSmoothness = findobj(guiContour, 'Tag', 'editSmoothWeight');
    smoothWeight = str2double(get(editSmoothness, 'String'));
    
    editIntensityWeight = findobj(guiContour, 'Tag', 'editIntensityWeight');
    intensityWeight = 0.001*str2double(get(editIntensityWeight, 'String'));
    
    editDeltaT = findobj(guiContour, 'Tag', 'editDeltaT');
    deltaT = str2double(get(editDeltaT, 'String'));
    
    editIterations = findobj(guiContour, 'Tag', 'editIterations');
    nIterations = str2double(get(editIterations, 'String'));
    
    % Crop and convert the input.
    tImage = double(previewData(yLimits, xLimits, tIdx));

    phiOut = ac_ChanVese_model(tImage, phiIn, ...
        smoothWeight, intensityWeight, deltaT, nIterations, 0);
    
    %% Draw the new contour.
    % Delete an existing contour.
    if ~isnan(contourHandleList(tIdx))
        delete(contourHandleList(tIdx))
    end % if
    
    % Create the new contour.
    phiPlaced = false(ySize, xSize);
    phiPlaced(yLimits, xLimits) = phiOut > 0;
    [~, contourPhi] = contour(axesPreview, phiPlaced, [0 0], ...
        'Color', 'g', ...
        'LineWidth', 2);
    
    % Add the contour handle to the list.
    contourHandleList(tIdx) = contourPhi;

    %% Store the updated contour handle list.
    setappdata(axesPreview, 'contourHandleList', contourHandleList);
    
    %% Turn off the mask display.
    rgnMaskHandle = getappdata(axesPreview, 'rgnMaskHandle');
    set(rgnMaskHandle, 'Visible', 'off');
    
    xtcontourCData = getappdata(guiContour, 'xtcontourCData');
    toggleMaskVisible = findobj(guiContour, 'Tag', 'toggleMaskVisible');
    set(toggleMaskVisible, ...
        'CData', xtcontourCData.MaskOff, ...
        'Value', 0)
    
    %% Reset the status bar.
    hStatus.setText('');
end % pushcontourcallback

