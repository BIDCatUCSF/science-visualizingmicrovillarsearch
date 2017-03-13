function edittimecallback(editTime, ~, editControl, sliderTime, editMaskTime, axesPreview, guiContour)
    % SLIDERTIMEPOINTCALLBACK Update the preview time point
    %   Detailed explanation goes here
    
    %% Get the updated time value.
    newValue = str2double(get(editTime, 'String'));
    
    %% Validate the input.
    if isnan(newValue)
        set(editTime, 'String', editControl.OldString)
        return
    end % if
        
    %% Get the valid time range.
    tMin = 1;
    tMax = get(sliderTime, 'Maximum');
    
    %% Update the edit box.
    newValue = round(newValue);
    
    if newValue < tMin;
        newValue = tMin;
        set(editTime, 'String', tMin)
        editControl.OldString = tMin;
        
    elseif newValue > tMax
        newValue = tMax;
        set(editTime, 'String', tMax)
        editControl.OldString = tMax;
        
    else
        set(editTime, 'String', newValue)
        editControl.OldString = newValue;

    end % if

    %% Update the slider string.
    set(sliderTime, ...
        'ToolTipText', num2str(newValue, '%u'), ...
        'Value', newValue)
    
    %% Update the preview image.
    updatepreview(editMaskTime, axesPreview, guiContour)
end % slidertimepointcallback

