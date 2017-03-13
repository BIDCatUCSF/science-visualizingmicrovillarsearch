function togglesinglezexpandcallback(hObject, ~, guiNd)
    % TOGGLESINGLEZEXPANDCALLBACK Toggle single z-plane duplication
    %
    %
    
    %% Get the cdata struct.
    xtndnderizerCData = getappdata(guiNd, 'xtndnderizerCData');
    
    %% Toggle the icon.
    if get(hObject, 'Value') == 1
        set(hObject, 'CData', xtndnderizerCData.SingleZExpandOn)
      
    else
        set(hObject, 'CData', xtndnderizerCData.SingleZExpandOff)
            
    end % if
end % togglesinglezexpandcallback
