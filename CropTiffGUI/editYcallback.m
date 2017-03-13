function editYcallback(hObject, ~, hObjectContainer, guiCrop)
%EDITYCALLBACK Updates the minimum and maximum y values for the cropped
%movies. R2015b
%
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

    %% Get the parameters struct
    structParameters = getappdata(guiCrop,'structParameters');
    
    %% Get the tag and converted string for the calling editbox
    hObjectTag = get(hObject,'Tag');    
    newValue = str2double(get(hObject,'String'));
    
    %% Test for a valid value and range   
    if isnan(newValue) || newValue <= 0
        set(hObject,'String', hObjectContainer.OldString)
    else
        switch hObjectTag
            case 'editYMin'
                % yMin needs to be less than yMax
                if newValue >= structParameters.yMax
                    set(hObject,'String',hObjectContainer.OldString)
                else
                    % Update control property
                    hObjectContainer.OldString = newValue;
                    
                    % Update the appdata
                    structParameters.yMin = newValue;
                    setappdata(guiCrop,'structParameters',structParameters)
                end % if
            case 'editYMax'
                % yMax needs to be greater than yMin
                if newValue <= structParameters.yMin
                    set(hObject,'String',hObjectContainer.OldString)
                else
                    % Update control property
                    hObjectContainer.OldString = newValue;
                    
                    % Update the appdata
                    structParameters.yMax = newValue;
                    setappdata(guiCrop,'structParameters',structParameters)
                end %if
        end %switch
        
    end % if
                
                    

end % editYcallback

