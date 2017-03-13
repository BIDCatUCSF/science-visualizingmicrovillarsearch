function toggleplaycallback(togglePlay, ~, guiContourer)
    % TOGGLEPLAYCALLBACK Continuously update the preview axes.
    
    %% Toggle the button's tooltip and cdata.
    xtcontourCData = getappdata(guiContourer, 'xtcontourCData');
    
    if get(togglePlay, 'Value')
        set(togglePlay, 'TooltipString', 'Pause')
        set(togglePlay, 'CData', xtcontourCData.Pause)
    
    else
        set(togglePlay, 'TooltipString', 'Play')
        set(togglePlay, 'CData', xtcontourCData.Play)
        
    end % if
    
    %% Start the timer.
    timerPlay = getappdata(togglePlay, 'timerPlay');
    
    if strcmp(timerPlay.Running, 'off')
        start(timerPlay)
        
    else
        stop(timerPlay)
        
    end % if
    
end % toggleplaycallback 