function togglezoomcallback(toggleZoom, ~, guiContourer)
    % TOGGLEZOOM Activate zooming
    %   Detailed explanation goes here
    
    %% Untoggle the data cursor and pan buttons.
    togglePan = findobj(guiContourer, 'Tag', 'togglePan');
    toggleDataCursor = findobj(guiContourer, 'Tag', 'toggleDataCursor');

    set([togglePan, toggleDataCursor], 'Value' , 0)
    
    %% Toggle zooming.
    if get(toggleZoom, 'Value')
        zoom(guiContourer, 'on')
        
    else
        zoom(guiContourer, 'off')
        
    end % if
end % togglezoomcallback

