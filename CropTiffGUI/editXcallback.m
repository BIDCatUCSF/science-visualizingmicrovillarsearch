function editXcallback(hObject, ~, hObjectContainer, guiCrop)
%EDITXCALLBACK Updates the minimum and maximum x values for the cropped
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
        set(hObject, 'String', hObjectContainer.OldString)
    else
        switch hObjectTag
            case 'editXMin'
                % xMin needs to be less than xMax
                if newValue >= structParameters.xMax
                    set(hObject,'String',hObjectContainer.OldString)
                else
                    % Update control property
                    hObjectContainer.OldString = newValue;
            
                    % Update the appdata
                    structParameters.xMin = newValue;
                    setappdata(guiCrop, 'structParameters',structParameters)
                end % if
            case 'editXMax'
                % xMax needs to be greater than xMin
                if newValue <= structParameters.xMin
                    set(hObject,'String',hObjectContainer.OldString)
                else
                    % Update control property
                    hObjectContainer.OldString = newValue;
                    
                    % Update the appdata
                    structParameters.xMax = newValue;
                    setappdata(guiCrop,'structParameters',structParameters)
                end %if
        end %switch
    end % if
    
end %editXMincallback

