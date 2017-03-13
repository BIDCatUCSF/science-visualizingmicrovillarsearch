function toggletimepersistcallback(hObject, ~, guiNd)
    % TOGGLETIMEINTERPOLATECALLBACK Display persistent image until frame
    % updates
    %
    %
    
    %% Get the cdata struct.
    xtndnderizerCData = getappdata(guiNd, 'xtndnderizerCData');
    
    %% Toggle the icon.
    if get(hObject, 'Value') == 1
        set(hObject, 'CData', xtndnderizerCData.TimePersistOn)
      
    else
        set(hObject, 'CData', xtndnderizerCData.TimePersistOff)
            
    end % if
end % toggletimepersistcallback
