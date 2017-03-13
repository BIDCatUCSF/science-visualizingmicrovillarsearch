function slidertimepointcallback(sliderTime, ~, guiNd)
    % SLIDERTIMEPOINTCALLBACK Update the preview time point
    %   Detailed explanation goes here
    
    %% Update the slider string.
    sliderValue = get(sliderTime, 'Value');
    set(sliderTime, 'ToolTipText', num2str(sliderValue, '%u'))
    
    %% Update the preview image.
    updatepreview(guiNd, 'Refresh', true)
end % slidertimepointcallback

