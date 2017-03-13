function pushInputFoldercallback(~,~,guiCrop,handles)
%PUSHINPUTFOLDERCALLBACK Prompts the user to select the folder containing the .tif files
%to be cropped. R2015b
%
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017
    
    %% Prompt the user to select a folder
    % check for a currently selected folder    
    structParameters = getappdata(guiCrop,'structParameters');
    inputFolder = structParameters.inpathdir;
   
    if ~isempty(inputFolder)
        folderSelection = uigetdir(inputFolder,'Select a folder of .tifs');
    else
        folderSelection = uigetdir(pwd,'Select a folder of .tifs');
    end % if
    
    %% Check for a canceled selection.
    if folderSelection(1) == 0 || strcmp(folderSelection,inputFolder)
        return
    end % if
    
    %% Store the folder as appdata
    structParameters.inpathdir = folderSelection;
    structParameters.outpathdir = folderSelection;
    setappdata(guiCrop,'structParameters',structParameters);
    % Updates both the input and output directory, so the user does not
    % have to renavigate all the paths to the folder
    handles.displayInPathDir.String = structParameters.inpathdir;
    handles.displayOutPathDir.String = structParameters.outpathdir;
end % pushInputFoldercallback

