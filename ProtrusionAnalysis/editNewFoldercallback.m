function editNewFoldercallback(hObject,~,hObjectContainer,guiPA)
%EDITNEWFOLDERCALLBACK Updates the folder name to be created when the
%program is run. R2015b
%
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017
    
    %% get the parameters struct
    structParameters = getappdata(guiPA,'structParameters');
    
    %% Get the string for the calling editbox  
    newFolder = get(hObject,'String');
    
    % If the edit box is empty, or if the name only contains non-alpha
    % numeric characters, use the old entry.
    if isempty(newFolder) || sum(isstrprop(newFolder,'alphanum'))<length(newFolder)
        set(hObject,'String',hObjectContainer.OldString)
    else
        % set the old string to the new folder and update appdata
        hObjectContainer.OldString = newFolder;        
        structParameters.newFolder = newFolder;
        setappdata(guiPA,'structParameters',structParameters)
    end %if
end %editNewFoldercallback

