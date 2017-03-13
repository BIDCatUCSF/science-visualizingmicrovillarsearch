function batchimarisimport(xImarisApp, guiNd)
    % BATCHIMARISIMPORT Batch import of all data sets in the folder
    %   Detailed explanation goes here
    
    %% Get the .nd set information.
    popupNd = findobj(guiNd, 'Tag', 'popupNd');
    ndFiles = getappdata(popupNd, 'ndFiles');
    
    for n = 1:length(ndFiles)
        if ~isempty(ndFiles(n).Data)
            % Get the parsed data.
            ndData = ndFiles(n).Data;

        else
            % Parse the file.
            ndFolder = getappdata(guiNd, 'ndFolder');
            ndData = ndimagecollect(fullfile(ndFolder, ndFiles(n).name));
            
            % Store the parsed data.
            ndFiles(n).Data = ndData;
            setappdata(popupNd, 'ndFiles', ndFiles);
        end % if

        ndBase = strrep(ndFiles(n).name, '.nd', '');
        ndimport(xImarisApp, ndBase, ndData, guiNd)
    end % for n
end % batchimarisimport




