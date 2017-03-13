function editFramecallback(hObject, ~, hObjectContainer, guiCrop)
%EDITFRAMECALLBACK Updates the starting and ending frame for the cropped
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
            case 'editFrameMin'
                % zMin needs to be less than zMax
                if newValue >= structParameters.zMax
                    set(hObject,'String',hObjectContainer.OldString)
                else
                    % Update control property
                    hObjectContainer.OldString = newValue;
            
                    % Update the appdata
                    structParameters.zMin = newValue;
                    setappdata(guiCrop, 'structParameters',structParameters)
                end %if
            case 'editFrameMax'
                % zMax needs to be greater than zMin
                if newValue <= structParameters.zMin
                    set(hObject,'String',hObjectContainer.OldString)
                else
                    % Update control property
                    hObjectContainer.OldString = newValue;
                    
                    % Update the appdata
                    structParameters.zMax = newValue;
                    setappdata(guiCrop,'structParameters',structParameters)
                end %if
        end %switch
    end %if
        
end %editFramecallback

