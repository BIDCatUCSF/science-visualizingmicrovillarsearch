function updatepreview(editMaskTime, axesPreview, guiContour)
    % UPDATEPREVIEW Summary of this function goes here
    %   Detailed explanation goes here
    
    %% Get the currently selected frame.
    editTime = findobj(guiContour, 'Tag', 'editTime');
    tIdx = str2double(get(editTime, 'String'));
    
    %% Get the image and contour arrays.
    previewData = getappdata(axesPreview, 'previewData');
    contourHandleList = getappdata(axesPreview, 'contourHandleList');

    %% Get the axes and image object.
    hImage = findobj(axesPreview, 'Type', 'Image');
    
    %% Update the image object.
    set(hImage, 'CData', previewData(:, :, tIdx))
    axis(axesPreview, 'image')
    
    %% Show the initial segmentation mask if toggled on.
    rgnMaskHandle = getappdata(axesPreview, 'rgnMaskHandle');
    
    if ~isempty(rgnMaskHandle)
        if tIdx == str2double(get(editMaskTime, 'String'))
            toggleMaskVisible = findobj(guiContour, 'Tag', 'toggleMaskVisible');
            if get(toggleMaskVisible, 'Value')
                set(rgnMaskHandle, 'Visible', 'on')
            end % if

        else
            set(rgnMaskHandle, 'Visible', 'off')
            
        end % if
    end % if
    
    %% Display the contour if present.
    if ~isnan(contourHandleList(tIdx))
        set(contourHandleList(tIdx), 'Visible', 'on')
    end % if
    
    % Hide all other contours.
    contourHandleList(tIdx) = [];
    contourHandleList(isnan(contourHandleList)) = [];
    set(contourHandleList, 'Visible', 'off')
end % updatepreview

