function pushcolorcallback(pushColor, ~, guiNd)
    % PUSHCOLORCALLBACK Set the channel pseudocolor
    %
    %
    
    %% Check for an existing color choice.
    waveColor = get(pushColor, 'UserData');
    
    if isempty(waveColor)
        waveColor = [1 1 1];
    end % if
    
    %% Call the MATLAB color picker GUI.
    waveToSet = regexp(get(pushColor, 'Tag'), '\d{1,}', 'Match', 'Once');
    newColor = selectcolor(waveColor, ...
        'Color', 'k', ...
        'Name', ['Channel ' num2str(waveToSet) ' color'], ...
        'Position', guiNd);
    
    %% Update the color choice.
    set(pushColor, 'UserData', newColor)
    
    %% Get the nd selection and stored nd data.
    popupNd = findobj(guiNd, 'Tag', 'popupNd');
    ndSelection = get(popupNd, 'Value');
    ndFiles = getappdata(popupNd, 'ndFiles');
    
    % If the user hasn't specified a folder yet, just return.
    if isempty(ndFiles)
        return
    end % if
    
    %% Get the .nd data.
    % Get the data folder.
    ndFolder = getappdata(guiNd, 'ndFolder');

    if ~isempty(ndFiles(ndSelection).Data)
        ndData = ndFiles(ndSelection).Data;
    
    else
        % Parse the file.
        ndData = ndimagecollect(fullfile(ndFolder, ndFiles(ndSelection).name));
        ndFiles(ndSelection).Data = ndData;

    end % if

    %% Call the preview update function.
    updatepreview(guiNd)
end % pushcolorcallback
