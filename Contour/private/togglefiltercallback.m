function togglefiltercallback(toggleFilter, ~, editMaskTime, axesPreview, guiContour)
    % TOGGLEFILTERCALLBACK Toggle filtering of the input images
    %   Detailed explanation goes here
    
    %% If the data isn't loaded yet, reset and return.
    if ~isappdata(axesPreview, 'xData')
        set(toggleFilter, 'Value', 0)
        return
    end % if
    
    %% Get the cdata struct.
    xtcontourCData = getappdata(guiContour, 'xtcontourCData');
    
    %% Get the image data.
    xData = getappdata(axesPreview, 'xData');
    previewData = getappdata(axesPreview, 'previewData');
    
    %% Toggle the icon and cropping region.
    if get(toggleFilter, 'Value') == 1
        %% Upate the toggle icon.
        set(toggleFilter, 'CData', xtcontourCData.FilterOn)
        
        %% Get the filter settings.
        editSigma = findobj(guiContour, 'Tag', 'editSigma');
        sigma = str2double(get(editSigma, 'String'));
        
        editOffset = findobj(guiContour, 'Tag', 'editOffset');
        offset = str2double(get(editOffset, 'String'));

        editScaleFactor = findobj(guiContour, 'Tag', 'editScaleFactor');
        scaleFactor = str2double(get(editScaleFactor, 'String'));
        
        %% Setup the status bar.
        hStatus = statusbar(guiContour, 'Filtering');
        hStatus.ProgressBar.setVisible(true)
        
        %% Filter the image.
        for t = 1:size(xData, 3)
            previewData(:, :, t) = imhighkemphasis(xData(:, :, t), ...
                sigma, offset, scaleFactor);
            hStatus.ProgressBar.setValue(t)
        end % for t
        
        %% Update the histogram.
        dataRange = [min(previewData(:)), max(previewData(:))];
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

        %% Store the updated preview data.
        setappdata(axesPreview, 'previewData', previewData)
        
        %% Set the axes clim.
        set(axesPreview, 'CLim', [min(previewData(:)), max(previewData(:))])
        
        %% Reset the status bar.
        hStatus.setText('')
        hStatus.ProgressBar.setValue(0)
        hStatus.ProgressBar.setVisible(false)
        
        %% Call the update function.
        updatepreview(editMaskTime, axesPreview, guiContour)
        
    else
        %% Upate the toggle icon.
        set(toggleFilter, 'CData', xtcontourCData.FilterOff)
        
        %% Restore the unfiltered data.
        previewData(:, :, :) = xData;
        
        %% Set the contrast limits for the axes to match the data range.
        dataRange = [min(previewData(:)), max(previewData(:))];
        set(axesPreview, 'Clim', double(dataRange).*[1.03 0.97])

        %% Update the histogram.
        binPos = dataRange(1):dataRange(end);
        fxImage = histc(previewData(:), binPos);
        fxImage = fxImage/max(fxImage);

        axesHistogram = findobj(guiContour, 'Tag', 'axesHistogram');
        set(axesHistogram, 'XLim', [binPos(1), binPos(end)])

        lineLowCLim = findobj(axesHistogram, 'Tag', 'lineLowCLim');
        set(lineLowCLim, 'XData', double(binPos(1))*[1.03 1.03])

        lineHighCLim = findobj(axesHistogram, 'Tag', 'lineHighCLim');
        set(lineHighCLim, 'XData', double(binPos(end))*[0.97 0.97]);

        barHistogram = findobj(axesHistogram, 'Tag', 'barHistogram');
        set(barHistogram, ...
            'XData', binPos, ...
            'YData', fxImage)
    
        %% Store the udpated data.
        setappdata(axesPreview, 'previewData', previewData)
        
        %% Call the update function.
        updatepreview(editMaskTime, axesPreview, guiContour)
        
    end % if
end % togglefiltercallback

