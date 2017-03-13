function togglepancallback(togglePan, ~, guiContourer)
    % TOGGLEPANCALLBACK Activate zooming
    %   Detailed explanation goes here
    
    %% Untoggle the data cursor and pan buttons.
    toggleZoom = findobj(guiContourer, 'Tag', 'toggleZoom');
    toggleDataCursor = findobj(guiContourer, 'Tag', 'toggleDataCursor');

    set([toggleZoom, toggleDataCursor], 'Value' , 0)
    
    %% Toggle zooming.
    if get(togglePan, 'Value')
        pan(guiContourer, 'on')
        
    else
        pan(guiContourer, 'off')
        
    end % if
end % togglepancallback

