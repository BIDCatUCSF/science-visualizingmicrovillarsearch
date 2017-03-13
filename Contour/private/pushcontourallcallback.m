function pushcontourallcallback(~, ~, editMaskTime, axesPreview, guiContour)
    % PUSHCONTOURALLCALLBACK Summary of this function goes here
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
    
    %% Initialize the mask and and setup cropping if active.
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
    
    %% Run the active contour algorithm.
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

    %% Update the status bar for segmenting the subsequent images.
    hStatus.setText('Contouring later time points');
    hStatus.ProgressBar.setMinimum(tIdx)
    hStatus.ProgressBar.setMaximum(size(previewData, 3))
    hStatus.ProgressBar.setVisible(true)
    
    %% Re-use the final phi from the initial time point contour.
    tPhi = phiOut;
    
    %% Contour the subsequent images.
    tForward = tIdx + 1:size(previewData, 3);
    for t = tForward
        %% Contour.
        tImage = double(previewData(yLimits, xLimits, t));
        
        % Initialize phi.
        tPhi = ac_reinit((tPhi > 0) - 0.5);
        
        % Run the active contour algorithm.
        tPhi = ac_ChanVese_model(tImage, tPhi, ...
            smoothWeight, intensityWeight, deltaT, nIterations, 0);
        
        %% Draw the new contour.
        % Delete an existing contour.
        if ~isnan(contourHandleList(t))
            delete(contourHandleList(t))
        end % if

        % Create the new contour.
        phiPlaced = false(ySize, xSize);
        phiPlaced(yLimits, xLimits) = tPhi > 0;
        [~, contourPhi] = contour(axesPreview, phiPlaced, [0 0], ...
            'Color', 'g', ...
            'LineWidth', 2);

        % Add the contour handle to the list.
        contourHandleList(t) = contourPhi;

        % Update the status bar.
        hStatus.ProgressBar.setValue(t)
    end % for t

    %% Update the status bar.
    hStatus.setText('Contouring previous time points');
    hStatus.ProgressBar.setMinimum(0)
    hStatus.ProgressBar.setMaximum(tIdx - 1)
    hStatus.ProgressBar.setValue(0)
    
    %% Re-use the final phi from the initial time point contour.
    tPhi = phiOut;
    
    %% Contour the previous images.
    tReverse = tIdx - 1:-1:1;
    for t = tReverse
        %% Contour.
        tImage = double(previewData(yLimits, xLimits, t));
        
        % Initialize phi.
        tPhi = ac_reinit((tPhi > 0) - 0.5);
        
        % Run the active contour algorithm.
        tPhi = ac_ChanVese_model(tImage, tPhi, ...
            smoothWeight, intensityWeight, deltaT, nIterations, 0);
        
        %% Draw the new contour.
        % Delete an existing contour.
        if ~isnan(contourHandleList(t))
            delete(contourHandleList(t))
        end % if

        % Create the new contour.
        phiPlaced = false(ySize, xSize);
        phiPlaced(yLimits, xLimits) = tPhi > 0;
        [~, contourPhi] = contour(axesPreview, phiPlaced, [0 0], ...
            'Color', 'g', ...
            'LineWidth', 2);

        % Add the contour handle to the list.
        contourHandleList(t) = contourPhi;

        % Update the status bar.
        hStatus.ProgressBar.setValue(tIdx - t)
    end % for t
    
    %% Store the updated contour handle list.
    setappdata(axesPreview, 'contourHandleList', contourHandleList);
    
    %% Update the slider and edit box to match the mask time.
    editTime = findobj(guiContour, 'Tag', 'editTime');
    
    if tIdx ~= str2double(get(editTime, 'String'))
        sliderTime = findobj(guiContour, 'Name', 'sliderTime');
        set(sliderTime, 'Value', tIdx)
        set(editTime, 'String', tIdx)
    end % if
    
    % Call the preview function update.
    updatepreview(editMaskTime, axesPreview, guiContour)

    %% Reset the status bar.
    hStatus.setText('');
    hStatus.ProgressBar.setValue(0)
    hStatus.ProgressBar.setVisible(false)
end % pushcontourallcallback

