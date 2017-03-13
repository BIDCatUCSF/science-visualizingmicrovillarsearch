function togglelabelscallback(hObject, ~, guiNd)
    % TOGGLELABELSCALLBACK Display labels on the output movie
    %
    %
    
    %% Get the cdata struct.
    xtndnderizerCData = getappdata(guiNd, 'xtndnderizerCData');
    
    %% Toggle the icon.
    if get(hObject, 'Value') == 1
        set(hObject, 'CData', xtndnderizerCData.LabelsOn)
      
    else
        set(hObject, 'CData', xtndnderizerCData.LabelsOff)
            
    end % if
end % togglelabelscallback
