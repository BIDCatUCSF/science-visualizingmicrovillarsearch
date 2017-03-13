function sliderzslicecallback(sliderZSlice, ~, guiNd)
    % SLIDERZSLICECALLBACK Update the preview z slice
    %   Detailed explanation goes here
    
    %% Update the slider string.
    sliderValue = get(sliderZSlice, 'Value');
    set(sliderZSlice, 'ToolTipText', num2str(sliderValue, '%u'))
    
    %% Update the preview image.
    updatepreview(guiNd, 'Refresh', true)
end % sliderzslicecallback

