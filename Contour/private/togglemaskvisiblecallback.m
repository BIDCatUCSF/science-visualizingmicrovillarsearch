function togglemaskvisiblecallback(toggleMaskVisible, ~, axesPreview, guiContour)
    % TOGGLEMASKVISIBLECALLBACK Summary of this function goes here
    %   Detailed explanation goes here
    
    %% If the data isn't loaded yet or there isn't a mask, reset and return.
    if ~isappdata(axesPreview, 'rgnMaskHandle')
        set(toggleMaskVisible, 'Value', 0)
        return
    end % if
    
    %% Get the button cdata.
    xtcontourCData = getappdata(guiContour, 'xtcontourCData');
    
    %% Toggle the mask visibiility.
    if get(toggleMaskVisible, 'Value')
        % Upate the toggle icon.
        set(toggleMaskVisible, 'CData', xtcontourCData.MaskOn)
        
        % Get the mask time point.
        editMaskTime = findobj(guiContour, 'Tag', 'editMaskTime');
        tMask = str2double(get(editMaskTime, 'String'));
        
        % Match the time point slider and edit box to the mask time point.
        editTime = findobj(guiContour, 'Tag', 'editTime');
        
        if tMask ~= str2double(editTime)
            set(editTime, 'String', tMask)

            sliderTime = findobj(guiContour, 'Tag', 'sliderTime');
            set(sliderTime, 'Value', tMask)

            % Call the preview update function.
            updatepreview(editMaskTime, axesPreview, guiContour)
        end % if
        
    else
        % Upate the toggle icon.
        set(toggleMaskVisible, 'CData', xtcontourCData.MaskOff)
        
        rgnMaskHandle = getappdata(axesPreview, 'rgnMaskHandle');
        set(rgnMaskHandle, 'Visible', 'off')
        
    end % if    
end % togglemaskvisiblecallback

