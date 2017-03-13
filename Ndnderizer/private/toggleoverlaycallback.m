function toggleoverlaycallback(hObject, ~, guiNd)
    % TOGGLEOVERLAYCALLBACK Output movie as a color overlay
    %
    %
    
    %% Get the cdata struct.
    xtndnderizerCData = getappdata(guiNd, 'xtndnderizerCData');
    
    %% Toggle the icon.
    if get(hObject, 'Value') == 1
        set(hObject, 'CData', xtndnderizerCData.OverlayOn)
      
    else
        set(hObject, 'CData', xtndnderizerCData.OverlayOff)
            
    end % if
end % toggleoverlaycallback
