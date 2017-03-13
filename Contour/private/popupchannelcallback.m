function popupchannelcallback(popupChannel, ~, xDataSet, guiContour)
    % POPUPCHANNELCALLBACK Gather the data for the selected channel
    %   Detailed explanation goes here
    
    %% Get the channel selection.
    cIdx = get(popupChannel, 'Value');
    
    %% Get the data dimensions.
    xSize = xDataSet.GetSizeX;
    ySize = xDataSet.GetSizeY;
    tSize = xDataSet.GetSizeT;
    
    %% Update the status bar.
    hStatus = statusbar(guiContour, 'Getting images');
    hStatus.ProgressBar.setMaximum(tSize)
    hStatus.ProgressBar.setValue(0)
    hStatus.ProgressBar.setVisible(true)
    
    %% Get the data.
    switch char(xDataSet.GetType)
        
        case 'eTypeUInt8'
            xData = zeros(ySize, xSize, tSize, 'uint8');
            for t = 1:tSize;
                xData(:, :, t) = rot90(xDataSet.GetDataSliceBytes(0, cIdx - 1, t - 1), 1);
                hStatus.ProgressBar.setValue(t)
            end % for t
            
        case 'eTypeUInt16'
            xData = zeros(ySize, xSize, tSize, 'uint16');
            for t = 1:tSize;
                xData(:, :, t) = rot90(xDataSet.GetDataSliceShorts(0, cIdx - 1, t - 1), 1);
                hStatus.ProgressBar.setValue(t)
            end % for t
                        
        case 'eTypeFloat'
            xData = zeros(ySize, xSize, tSize, 'single');
            for t = 1:tSize;
                xData(:, :, t) = rot90(xDataSet.GetDataSliceFloats(0, cIdx - 1, t - 1), 1);
                hStatus.ProgressBar.setValue(t)
            end % for t
            
    end % switch
    
    %% Store the image array, a preview copy of the array and a blank contour array.
    axesPreview = findobj(guiContour, 'Tag', 'axesPreview');
    
    setappdata(axesPreview, 'xData', xData)
    
    previewData = zeros(size(xData), 'like', xData);
    previewData(:, :, :) = xData;
    setappdata(axesPreview, 'previewData', previewData)
    
    % Delete existing contours (for loading new data).
    contourHandleList = getappdata(axesPreview, 'contourHandleList');
    
    delete(contourHandleList(ishandle(contourHandleList)))
    contourHandleList = nan(1, tSize);
    setappdata(axesPreview, 'contourHandleList', contourHandleList)
    
    %% Update the histogram.
    dataRange = [min(xData(:)), max(xData(:))];
    binPos = dataRange(1):dataRange(end);
    fxImage = histc(previewData(:), binPos);
    fxImage = fxImage/max(fxImage);
    
    axesHistogram = findobj(guiContour, 'Tag', 'axesHistogram');
    set(axesHistogram, 'XLim', [binPos(1), binPos(end)])
    
    lineLowCLim = findobj(axesHistogram, 'Tag', 'lineLowCLim');
    set(lineLowCLim, 'XData', double(binPos(1))*[1.03 0.03])
    
    lineHighCLim = findobj(axesHistogram, 'Tag', 'lineHighCLim');
    set(lineHighCLim, 'XData', double(binPos(end))*[0.97 0.97]);
    
    barHistogram = findobj(axesHistogram, 'Tag', 'barHistogram');
    set(barHistogram, ...
        'XData', binPos, ...
        'YData', fxImage)
    
    % Set the contrast limits for the axes to match the data range.
    set(axesPreview, 'Clim', [1.03*double(binPos(1)), double(binPos(end))*0.97])

    %% Reset the filter button.
    toggleFilter = findobj(guiContour, 'Tag', 'toggleFilter');
        xtcontourCData = getappdata(guiContour, 'xtcontourCData');
    set(toggleFilter, ...
        'CData' , xtcontourCData.FilterOff, ...
        'Value', 0)
    
    %% Delete any existing mask and reset the mask toggle buttons.
    rgnMask = getappdata(axesPreview, 'rgnMask');
    
    if ~isempty(rgnMask)
        delete(rgnMask)
        rmappdata(axesPreview, 'rgnMask')
        rmappdata(axesPreview, 'rgnMaskHandle')
    end % if
    
    toggleOffList = findobj(guiContour, '-regexp', ...
        'Tag', 'toggleMask(Ellipse|Rectangle|Freehand|Threshold)$');
    set(toggleOffList, 'Value', 0)
    
    toggleMaskVisible = findobj(guiContour, 'Tag', 'toggleMaskVisible');
    set(toggleMaskVisible, ...
        'CData', xtcontourCData.MaskOff, ...
        'Value', 0)

        %% Activate the play button and time edit box and update the slider maximum.
    togglePlay = findobj(guiContour, 'Tag', 'togglePlay');
    editTime = findobj(guiContour, 'Tag', 'editTime');
    set([togglePlay, editTime], 'Enable', 'on')

    sliderTime = findobj(guiContour, 'Name', 'sliderTime');
    set(sliderTime, 'Maximum', tSize)
    
    %% Call the axes update function.
    editMaskTime = findobj(guiContour, 'Tag', 'editMaskTime');
    updatepreview(editMaskTime, axesPreview, guiContour)

    %% Reset the status bar.
    hStatus.setText('');
    hStatus.ProgressBar.setValue(0)
    hStatus.ProgressBar.setVisible(false)
end % popupchannelcallback

