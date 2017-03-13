function toggledatacursorcallback(toggleDataCursor, ~, guiContourer)
    % TOGGLEDATACURSORCALLBACK Activate zooming
    %   Detailed explanation goes here
    
    %% Untoggle the zoom and pan buttons.
    toggleZoom = findobj(guiContourer, 'Tag', 'toggleZoom');
    togglePan = findobj(guiContourer, 'Tag', 'togglePan');

    set([toggleZoom, togglePan], 'Value' , 0)
    
    %% Toggle data cursor.
    if get(toggleDataCursor, 'Value')
        datacursormode(guiContourer, 'on')
        
    else
        datacursormode(guiContourer, 'off')
        
    end % if
end % toggledatacursorcallback

