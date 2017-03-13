function pushimarisimportcallback(~, ~, guiNd)
    % PUSHIMARISIMPORTCALLBACK Import .nd data to Imaris
    %
    %   ©2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/

    %% Connect to Imaris.
    xImarisID = getappdata(guiNd, 'xImarisID');
    
    if ~isempty(xImarisID)
        xImarisApp = xtconnectimaris(xImarisID);

    else        
        [xImarisApp, xImarisID] = xtconnectimaris;
        
        setappdata(guiNd, 'xImarisID', xImarisID)
        
    end % if
    
    %% Check for a batch import request.
    checkBatchImport = findobj(guiNd, 'Tag', 'checkBatchImport');
    
    if get(checkBatchImport, 'Value')
        batchimarisimport(xImarisApp, guiNd)
    
    else    
        %% Get the .nd set information.
        popupNd = findobj(guiNd, 'Tag', 'popupNd');
        ndFiles = getappdata(popupNd, 'ndFiles');
        ndSelection = get(popupNd, 'Value');
        
        ndBase = strrep(ndFiles(ndSelection).name, '.nd', '');
        ndData = ndFiles(ndSelection).Data;

        %% Call the import function.
        ndimport(xImarisApp, ndBase, ndData, guiNd)
    end % if
end % pushimarisimportcallback
