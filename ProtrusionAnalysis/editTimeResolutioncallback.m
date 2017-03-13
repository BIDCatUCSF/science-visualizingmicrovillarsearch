function editTimeResolutioncallback(hObject, ~, hObjectContainer, guiPA)
%editTimeResolutioncallback Checks to make sure input is a valid number.
%R2015b 
% 
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

    %% Get the parameters structure
    structParameters = getappdata(guiPA, 'structParameters');
    
    %% Get the converted strings for the calling editbox
    newValue = str2double(get(hObject, 'String'));
    
    %% Test for a valid value
    % Input must be a number greater than zero
    if isnan(newValue) || newValue <= 0
        set(hObject, 'String', hObjectContainer.OldString)
    else
        % Update the control property
        hObjectContainer.OldString = newValue;
        
        % Update the appdata
        structParameters.timeRes = newValue;
        setappdata(guiPA,'structParameters',structParameters)
    end % if
    
end % editTimeResolutioncallback

