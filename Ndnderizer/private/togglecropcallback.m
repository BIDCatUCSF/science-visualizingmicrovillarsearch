function togglecropcallback(toggleCrop, ~, guiNd, axesPreview)
    % TOGGLECROPCALLBACK Toggle region of interest selection for the the output
    %
    %
    
    %% Get the cdata struct.
    xtndnderizerCData = getappdata(guiNd, 'xtndnderizerCData');
    
    %% Toggle the icon and cropping region.
    if get(toggleCrop, 'Value') == 1
        % Upate the toggle icon.
        set(toggleCrop, 'CData', xtndnderizerCData.CropOn)
        
        % Check for exisiting cropping coordinates.
        lastCropPos = getappdata(axesPreview, 'lastCropPos');
        
        % Create a constraint function.
        dragLimFcn = makeConstrainToRectFcn('imrect', ...
            xlim(axesPreview), ylim(axesPreview));

        if isempty(lastCropPos)
            % Create a cropping rectangle.
            rgnCrop = ndnderizerrect(axesPreview, 'PositionConstraintFcn', dragLimFcn);
            
        else
            % Create a rectangle with the existing crop dimensions.
            rgnCrop = ndnderizerrect(axesPreview, lastCropPos, 'PositionConstraintFcn', dragLimFcn);
        
        end % if
        
        % Store the region.
        setappdata(axesPreview, 'rgnCrop', rgnCrop)
        
    else
        % Upate the toggle icon.
        set(toggleCrop, 'CData', xtndnderizerCData.CropOff)
        
        % Store the region position vector. If the user toggles the ROI
        % back on, we recreate it at the stored position.
        rgnCrop = getappdata(axesPreview, 'rgnCrop');
        lastCropPos = rgnCrop.getPosition;
        setappdata(axesPreview, 'lastCropPos', lastCropPos)
            
        % Delete the region.
        delete(rgnCrop)
        rmappdata(axesPreview, 'rgnCrop')
        
        % Close the position GUI if open.
        guiRegionPos = getappdata(guiNd, 'guiRegionPos');
        if ~isempty(guiRegionPos)
            delete(guiRegionPos)
            rmappdata(guiNd, 'guiRegionPos')
        end % if
    end % if
end % togglecropcallback
