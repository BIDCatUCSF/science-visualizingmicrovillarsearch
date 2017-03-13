function editProtrusionSizecallback(hObject, ~, hObjectContainer, guiPA)
%editProtrusionSizecallback Updates the size of the protrusion with allowed
%values (integers). R2015b
% 
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

    %% Get the parameters structure
    structParameters = getappdata(guiPA,'structParameters');
    
    %% Get the converted string for the calling editbox
    newValue = str2double(get(hObject,'String'));
    
    %% Test for a valid value
    % Input must be a number greater than zero
    if isnan(newValue) || newValue <= 0
        set(hObject, 'String', hObjectContainer.OldString)
    else 
        % Test to see if the number is an integer
        if ~mod(newValue,1) == 1
            % Update the control property
            hObjectContainer.OldString = newValue;
            
            % Update the appdata
            structParameters.sizeProtrusions = newValue;
            setappdata(guiPA,'structParameters',structParameters)
        else
            % If not a whole number, round
            newValue = round(newValue);
            
            % Update the control property
            hObjectContainer.OldString = newValue;
            
            % Update the appdata
            structParameters.sizeProtrusions = newValue;
            setappdata(guiPA,'structParameters',structParameters)
            % Reset the string visible in the GUI
            set(hObject, 'String', hObjectContainer.OldString)
        end % if
    end % if
            

end % editProtrusionSizecallback

