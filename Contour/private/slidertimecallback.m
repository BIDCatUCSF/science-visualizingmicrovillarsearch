function slidertimecallback(sliderTime, ~, editMaskTime, axesPreview, guiContour)
    % SLIDERTIMEPOINTCALLBACK Update the preview time point
    %   Detailed explanation goes here
    
    %% Update the slider string.
    sliderValue = get(sliderTime, 'Value');
    set(sliderTime, 'ToolTipText', num2str(sliderValue, '%u'))
    
    %% Update the edit box.
    editTime = findobj(guiContour, 'Tag', 'editTime');
    set(editTime, 'String', sliderValue)
    
    %% Update the preview image.
    updatepreview(editMaskTime, axesPreview, guiContour)
end % slidertimecallback

