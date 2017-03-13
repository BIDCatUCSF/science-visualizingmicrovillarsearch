function pushInputFilecallback( ~,~,guiPA,handles )
%pushInputFilecallback Prompts the user to find the .tif file to be
%analyzed. R2015b
%
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

    %% Prompt the user to select a file
    % check for a currently selected file
    structParameters = getappdata(guiPA,'structParameters');
    inputFile = structParameters.inpathfile;
    
    if ~isempty(inputFile)
        [fileSelection,pathSelection] = uigetfile({'*.tif'},'Select .tif',structParameters.outpathdir);
    else
        [fileSelection,pathSelection] = uigetfile({'*.tif'},'Select .tif');
    end % if

    %% Check for a canceled selection.
    if fileSelection(1) == 0 || strcmp(fileSelection,inputFile)
        return
    end % if
    
    %% Store the file as appdata
    % wholePath = strcat(pathSelection,fileSelection);
    structParameters.inpathfile = fileSelection;
    structParameters.inpathdir = pathSelection;
    structParameters.outpathdir = pathSelection; 
    setappdata(guiPA,'structParameters',structParameters);
    % Updates both the input and output directory, so the user does not
    % have to renavigate all the paths to the folder
    handles.displayInPathFile.String = structParameters.inpathfile;
    handles.displayOutPathDir.String = structParameters.outpathdir;

end

