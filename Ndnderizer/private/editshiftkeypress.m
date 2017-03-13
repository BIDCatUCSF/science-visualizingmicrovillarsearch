function editshiftkeypress(hEdit, editEvent, guiNd)
    % editshiftkeypress 
    %   Detailed explanation goes here
    
    %% Check for an up or down press.
    switch editEvent.Key
        
        case 'uparrow'
            editValue = str2double(get(hEdit, 'String'));
            editValue = editValue + 1;
            set(hEdit, 'String', editValue)
            
        case 'downarrow'
            editValue = str2double(get(hEdit, 'String'));
            editValue = editValue - 1;
            set(hEdit, 'String', editValue)
            
    end % switch
    
    %% Call the preview update function.
    updatepreview(guiNd)
end % editshiftkeypress

