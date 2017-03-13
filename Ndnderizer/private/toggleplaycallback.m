function toggleplaycallback(togglePlay, ~, guiNd)
    % TOGGLEPLAYCALLBACK Continuously update the preview axes.
    
    %% Toggle the button's tooltip and cdata.
    xtndnderizerCData = getappdata(guiNd, 'xtndnderizerCData');
    
    if get(togglePlay, 'Value')
        set(togglePlay, 'TooltipString', 'Pause')
        set(togglePlay, 'CData', xtndnderizerCData.Pause)
    
    else
        set(togglePlay, 'TooltipString', 'Play')
        set(togglePlay, 'CData', xtndnderizerCData.Play)
        
    end % if
    
    %% Start the timer.
    playTimer = getappdata(togglePlay, 'playTimer');
    
    if strcmp(playTimer.Running, 'off')
        start(playTimer)
        
    else
        stop(playTimer)
        
    end % if
    
end % toggleplaycallback 