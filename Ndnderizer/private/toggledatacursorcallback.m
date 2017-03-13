function toggledatacursorcallback(toggleDataCursor, ~, guiNd)
    % TOGGLEDATACURSORCALLBACK Activate zooming
    %   Detailed explanation goes here
    
    %% Untoggle the zoom and pan buttons.
    toggleZoom = findobj(guiNd, 'Tag', 'toggleZoom');
    togglePan = findobj(guiNd, 'Tag', 'togglePan');

    set([toggleZoom, togglePan], 'Value' , 0)
    
    %% Toggle data cursor.
    if get(toggleDataCursor, 'Value')
        datacursormode(guiNd, 'on')
        
    else
        datacursormode(guiNd, 'off')
        
    end % if
end % toggledatacursorcallback

