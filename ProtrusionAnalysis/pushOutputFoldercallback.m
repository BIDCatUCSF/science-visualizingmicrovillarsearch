function pushOutputFoldercallback(~,~,guiCrop,handles)
%PUSHOUTPUTFOLDERCALLBACK Prompts the user to select the folder for the
%cropped files to be saved in. R2015b
%
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

    %% Prompt the user to select a folder
    % check for a currently selected folder    
    structParameters = getappdata(guiCrop,'structParameters');
    outputFolder = structParameters.outpathdir;
    
    if ~isempty(outputFolder)
        folderSelection = uigetdir(outputFolder,'Select a folder to place Output');
    else
        folderSelection = uigetdir(pwd,'Select a folder to place Output');
    end % if
    
    %% Check for a canceled selection.
    if folderSelection(1) == 0 || strcmp(folderSelection,outputFolder)
        return
    end %if
    
    %% Store the folder as appdata
    structParameters.outpathdir = folderSelection;
    setappdata(guiCrop,'structParameters',structParameters);
    % Update the string on the GUI
    handles.displayOutPathDir.String = structParameters.outpathdir;
end

