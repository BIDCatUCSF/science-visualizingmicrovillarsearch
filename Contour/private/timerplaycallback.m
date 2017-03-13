function timerplaycallback(~, ~, sliderTime, editTime, editMaskTime, axesPreview, guiContour)
    % TIMERPLAYCALLBACK Summary of this function goes here
    %   Detailed explanation goes here
    
    %% Update the slider string.
    sliderValue = get(sliderTime, 'Value');
    if sliderValue < get(sliderTime, 'Maximum')
        set(sliderTime, ...
            'Value', sliderValue + 1, ...
            'ToolTipText', num2str(sliderValue + 1, '%u'))
        set(editTime, 'String', sliderValue + 1)

    else
        set(sliderTime, ...
            'Value', 1, ...
            'ToolTipText', num2str(1, '%u'))
        set(editTime, 'String', 1)

    end % if
    
    %% Update the preview image.
    updatepreview(editMaskTime, axesPreview, guiContour)
end % timerplaycallback

