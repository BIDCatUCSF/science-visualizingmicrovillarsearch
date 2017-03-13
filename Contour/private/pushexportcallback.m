function pushexportcallback(~, ~, xImarisApp, mIdx, axesPreview, guiContour)
    % PUSHEXPORTCALLBACK Export the mask data to Imaris.
    %   Detailed explanation goes here
    
    
    %% Clone the data set.
    cDataSet = xImarisApp.GetDataSet.Clone;
    
    %% Get the data set size.
    cSize = cDataSet.GetSizeC;
    xSize = cDataSet.GetSizeX;
    ySize = cDataSet.GetSizeY;
    tSize = cDataSet.GetSizeT;
    
    %% Expand the data set for the mask channel if needed.
    if cSize - 1 < mIdx
        cDataSet.SetSizeC(cSize + 1)
    end % if
    
    %% Get the contours.
    contourHandleList = getappdata(axesPreview, 'contourHandleList');
    
    %% Find the time points that have contours.
    tIdxs = 1:tSize;
    tContourIdxs = tIdxs(contourHandleList ~= 0);
    
    %% Setup the status bar.
    hStatus = statusbar(guiContour, 'Transferring contours');
    hStatus.ProgressBar.setMaximum(length(tContourIdxs))
    hStatus.ProgressBar.setValue(0)
    hStatus.ProgressBar.setVisible(true)
    
    %% Create a mask from each contour and transfer to the data set.
    for t = tContourIdxs
        %% Get the contour x and y data.
        tContour = get(contourHandleList(t));
        contourXs = tContour.ContourMatrix(1, :);
        contourYs = tContour.ContourMatrix(2, :);
        
        %% Convert all the contours in the contour matrix into a single mask.
        % Initialize the mask and index in the contour matrix.
        maskContour = false(xSize, ySize);
        c = 1;
        
        while c < numel(contourYs)
            % Get the number of vertices in the cth matrix.
            vNumber = contourYs(c);
            
            % Get the vertices for the cth contour. Translating to Imaris
            % coordinates requires flipping Y, then swapping X and Y during
            % mask creation in the next step.
            cXs = contourXs(c + 1:c + vNumber);
            cYs = ySize - contourYs(c + 1:c + vNumber);
            
            % Create the mask from the contour.
            maskContour = maskContour | ...
                poly2mask(cYs, cXs, xSize, ySize);
            
            % Update the index in the contour matrix.
            c = c + vNumber + 1;
        end % while
        
        %% Transfer the mask to Imaris.
        cDataSet.SetDataSliceBytes(maskContour, 0, mIdx, t - 1)
        
        %% Update the status bar.
        hStatus.ProgressBar.setValue(hStatus.ProgressBar.getValue + 1)
    end % for t
    
    %% Set the mask channel color.
    popupChannels = findobj(guiContour, 'Tag', 'popupChannels');
    sourceChannelIdx = get(popupChannels, 'Value');
    sourceChannelColor = rgb32bittotriplet(cDataSet.GetChannelColorRGBA(...
        sourceChannelIdx - 1));
    
    contourChannelColor = rgbtripleto32bit(sourceChannelColor, 0.5);
    cDataSet.SetChannelColorRGBA(mIdx, contourChannelColor);
    
    %% Set the mask channel display range.
    cDataSet.SetChannelRange(mIdx, 0, 1)
    
    %% Set the mask channel name.
    sourceChannelName = char(cDataSet.GetChannelName(sourceChannelIdx - 1));
    
    contourChannelName = [sourceChannelName ' contours'];
    cDataSet.SetChannelName(mIdx, contourChannelName);
    
    %% Store the contour parameters as Imaris parameters.
    % Create the section name.
    xParameterSection = ['Channel ' num2str(mIdx - 1)];
    
    % Get the contour parameters.
    editSmoothWeight = findobj(guiContour, 'Tag', 'editSmoothWeight');
    smoothWeight = get(editSmoothWeight, 'String');
    cDataSet.SetParameter(xParameterSection, 'SmoothWeight', smoothWeight)
    
    editIntensityWeight = findobj(guiContour, 'Tag', 'editIntensityWeight');
    intensityWeight = get(editIntensityWeight, 'String');
    cDataSet.SetParameter(xParameterSection, 'IntensityWeight', intensityWeight)

    editDeltaT = findobj(guiContour, 'Tag', 'editDeltaT');
    deltaT = get(editDeltaT, 'String');
    cDataSet.SetParameter(xParameterSection, 'DeltaT', deltaT)
    
    editIterations = findobj(guiContour, 'Tag', 'editIterations');
    nIterations = get(editIterations, 'String');
    cDataSet.SetParameter(xParameterSection, 'Iterations', nIterations)
    
    editMaskTime = findobj(guiContour, 'Tag', 'editMaskTime');
    maskTime = get(editMaskTime, 'String');
    cDataSet.SetParameter(xParameterSection, 'MaskTime', maskTime)    
    
    %% If the data was filtered, store the filter parameters.
    toggleFilter = findobj(guiContour, 'Tag', 'toggleFilter');
    
    if get(toggleFilter, 'Value')
        editSigma = findobj(guiContour, 'Tag', 'editSigma');
        sigma = get(editSigma, 'String');
        cDataSet.SetParameter(xParameterSection, 'Sigma', sigma)    

        editOffset = findobj(guiContour, 'Tag', 'editOffset');
        offset = get(editOffset, 'String');
        cDataSet.SetParameter(xParameterSection, 'Offset', offset)

        editScaleFactor = findobj(guiContour, 'Tag', 'editScaleFactor');
        scaleFactor = get(editScaleFactor, 'String');
        cDataSet.SetParameter(xParameterSection, 'ScaleFactor', scaleFactor)  
    end % if
    
    %% Place the duplicate data set.
    hStatus.setText('Placing data')
    xImarisApp.SetDataSet(cDataSet)
    
    %% Reset the status bar.
    hStatus.setText('');
    hStatus.ProgressBar.setValue(0)
    hStatus.ProgressBar.setVisible(false)
end % pushexportcallback

