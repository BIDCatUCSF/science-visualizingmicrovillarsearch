function togglezoomcallback(toggleZoom, ~, guiNd)
    % TOGGLEZOOM Activate zooming
    %   Detailed explanation goes here
    
    %% Untoggle the data cursor and pan buttons.
    togglePan = findobj(guiNd, 'Tag', 'togglePan');
    toggleDataCursor = findobj(guiNd, 'Tag', 'toggleDataCursor');

    set([togglePan, toggleDataCursor], 'Value' , 0)
    
    %% Toggle zooming.
    if get(toggleZoom, 'Value')
        zoom(guiNd, 'on')
        
    else
        zoom(guiNd, 'off')
        
    end % if
end % togglezoomcallback

