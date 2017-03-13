function togglecropcallback(toggleCrop, ~, axesPreview, guiContour)
    % TOGGLECROPCALLBACK Toggle region of interest selection for the the output
    %
    %
    
    %% Get the cdata struct.
    xtcontourCData = getappdata(guiContour, 'xtcontourCData');
    
    %% Toggle the icon and cropping region.
    if get(toggleCrop, 'Value') == 1
        % Upate the toggle icon.
        set(toggleCrop, 'CData', xtcontourCData.CropOn)
        
        % Check for exisiting cropping coordinates.
        lastCropPos = getappdata(axesPreview, 'lastCropPos');
        
        % Create a constraint function.
        dragLimFcn = makeConstrainToRectFcn('imrect', ...
            xlim(axesPreview), ylim(axesPreview));

        if isempty(lastCropPos)
            % Create a cropping rectangle.
            rgnCrop = croprect(axesPreview, 'PositionConstraintFcn', dragLimFcn);
            set(rgnCrop, 'DisplayName', 'Crop')
            
            % If the user cancelled, reset.
            if isempty(rgnCrop)
                set(toggleCrop, 'CData', xtcontourCData.CropOff, 'Value', 0)
            end % if
            
        else
            % Create a rectangle with the existing crop dimensions.
            rgnCrop = croprect(axesPreview, lastCropPos, 'PositionConstraintFcn', dragLimFcn);
            set(rgnCrop, 'DisplayName', 'Crop')
        
        end % if
        
        % Store the region.
        setappdata(axesPreview, 'rgnCrop', rgnCrop)
        
    else
        % Upate the toggle icon.
        set(toggleCrop, 'CData', xtcontourCData.CropOff)
        
        % Store the region position vector. If the user toggles the ROI
        % back on, we recreate it at the stored position.
        rgnCrop = getappdata(axesPreview, 'rgnCrop');
        lastCropPos = rgnCrop.getPosition;
        setappdata(axesPreview, 'lastCropPos', lastCropPos)
            
        % Delete the region.
        delete(rgnCrop)
        rmappdata(axesPreview, 'rgnCrop')
        
        % Close the position GUI if open.
        guiRegionPos = getappdata(guiContour, 'guiRegionPos');
        if ~isempty(guiRegionPos)
            delete(guiRegionPos)
            rmappdata(guiContour, 'guiRegionPos')
        end % if
    end % if
end % togglecropcallback
