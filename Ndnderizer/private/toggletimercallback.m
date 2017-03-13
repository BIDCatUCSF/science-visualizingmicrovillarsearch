function playtimercallback(~, ~, sliderTime, guiNd)
    % TOGGLETIMERCALLBACK Summary of this function goes here
    %   Detailed explanation goes here
    
    %% Update the slider string.
    sliderValue = get(sliderTime, 'Value');
    if sliderValue < get(sliderTime, 'Maximum')
        set(sliderTime, ...
            'Value', sliderValue + 1, ...
            'ToolTipText', num2str(sliderValue + 1, '%u'))
    
    else
        set(sliderTime, ...
            'Value', 1, ...
            'ToolTipText', num2str(1, '%u'))

    end % if
    
    %% Update the preview image.
    updatepreview(guiNd, 'Refresh', true)
end % playtimercallback