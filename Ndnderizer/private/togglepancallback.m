function togglepancallback(togglePan, ~, guiNd)
    % TOGGLEPANCALLBACK Activate zooming
    %   Detailed explanation goes here
    
    %% Untoggle the data cursor and pan buttons.
    toggleZoom = findobj(guiNd, 'Tag', 'toggleZoom');
    toggleDataCursor = findobj(guiNd, 'Tag', 'toggleDataCursor');

    set([toggleZoom, toggleDataCursor], 'Value' , 0)
    
    %% Toggle zooming.
    if get(togglePan, 'Value')
        pan(guiNd, 'on')
        
    else
        pan(guiNd, 'off')
        
    end % if
end % togglepancallback

