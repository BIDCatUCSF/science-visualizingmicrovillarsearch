function pushfolderopencallback(~, ~, guiNd)
    % PUSHFOLDEROPENCALLBACK Return .nd data sets in a folder.
    %
    %
    
    %% Prompt the user to select a folder.
    % Check for a currently selected folder.
    ndFolder = getappdata(guiNd, 'ndFolder');
    
    if ~isempty(ndFolder)
        folderSelection = uigetdir(ndFolder, 'Select a folder of images.');
        
    else
        folderSelection = uigetdir(pwd, 'Select a folder of images.');
        
    end % if
    
    %% Check for a canceled selection.
    if folderSelection(1) == 0 || strcmp(folderSelection, ndFolder)
        return
    end % if
    
    %% Store the folder as appdata.
    ndFolder = folderSelection;
    setappdata(guiNd, 'ndFolder', ndFolder);
    
    %% Update the status bar to display the selected folder.
    dataFolderStatusString = ['Current folder: ' strrep(ndFolder, '\', '\\')];
    statusbar(guiNd, dataFolderStatusString)
    
    %% Populate the .nd popup with the .nd files in the folder.
    % Get the .nd files.
    ndFiles = dir(fullfile(ndFolder, '*.nd'));
    
    % Sort the .nd files into natural sort order.
    [~, natSortOrder] = sort_nat({ndFiles.name});
    ndFiles = ndFiles(natSortOrder);
    
    % If no .nd files are found, empty out the selection GUI elements.
    if isempty(ndFiles)
        % Empty out the listboxes and unselect.
        popupNd = findobj(guiNd, 'Tag', 'popupNd');
        set(popupNd, ...
            'String', {''}, ...
            'Value', 1)

        listboxStage = findobj(guiNd, 'Tag', 'listboxStage');
        set(listboxStage, ...
            'String', {}, ...
            'Value', [])
                
    else
        %% Select the first .nd file and populate the popup.
        popupNd = findobj(guiNd, 'Tag', 'popupNd');
        set(popupNd, ...
            'String', {ndFiles.name}, ...
            'Value', 1)

        % Gather the information for the first nd file.
        ndData = ndimagecollect(fullfile(ndFolder, ndFiles(1).name));

        %% Store the .nd file list with the parsed data.
        ndFiles(1).Data = ndData;
        setappdata(popupNd, 'ndFiles', ndFiles);

        %% Clear the stage positions listbox.
        listboxStage = findobj(guiNd, 'Tag', 'listboxStage');
        set(listboxStage, 'String', '')
    end % if
    
    %% Clear the image axes.
    axesPreview = findobj(guiNd, 'Tag', 'axesPreview');
    hImage = findobj(axesPreview, 'Type', 'Image');
    set(hImage, 'CData', zeros([256, 256, 3], 'uint8'))
    
    %% Delete any existing wavelength editing GUI elements.
    wavelengthObjects = findobj(guiNd, '-regexp', 'Tag', ...
        'checkWave\d|textWave\d|pushColor\d|editXWave\d|editYWave\d|axesLimWave\d');
    delete(wavelengthObjects)
end % pushfolderopencallback
