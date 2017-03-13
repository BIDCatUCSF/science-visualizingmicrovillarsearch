function togglemaskcallback(toggleCaller, ~, axesPreview, guiContour)
    % TOGGLEMASKCALLBACK Toggle initial mask type
    %   Detailed explanation goes here
    
    %% Check for an already-drawing flag.
    if getappdata(guiContour, 'isDrawing');
        set(toggleCaller, 'Value', 0)
        return
    end % if
    
    %% Delete any existing mask.
    rgnMask = getappdata(axesPreview, 'rgnMask');
    
    if ~isempty(rgnMask)
        delete(rgnMask)
        rmappdata(axesPreview, 'rgnMask')
        rmappdata(axesPreview, 'rgnMaskHandle')
    end % if
    
    %% If the toggle is going to an off state, reset and return.
    editMaskTime = findobj(guiContour, 'Tag', 'editMaskTime');

    if get(toggleCaller, 'Value') == 0
        % Turn off the mask time point indicator.
        set(editMaskTime, 'String', ' ')
        
        % Untoggle the mask visible toggle.
        xtcontourCData = getappdata(guiContour, 'xtcontourCData');
        toggleMaskVisible = findobj(guiContour, 'Tag', 'toggleMaskVisible');
        set(toggleMaskVisible, ...
            'CData', xtcontourCData.MaskOff, ...
            'Value', 0)
        
        return    
    end % if
    
    %% Get the status bar.
    hStatus = statusbar(guiContour, '');
    
    %% Get the Tag for the calling toggle button.
    toggleTag = get(toggleCaller, 'Tag');
    
    %% Set the drawing flag.
    setappdata(guiContour, 'isDrawing', 1)
    
    %% Setup the initial mask based on the calling toggle tag.
    switch toggleTag
        
        case 'toggleMaskEllipse'
            %% Untoggle the other mask toggles.
            toggleOffList = findobj(guiContour, '-regexp', ...
                'Tag', 'toggleMask(Rectangle|Freehand|Threshold)$');
            set(toggleOffList, 'Value', 0)
            
            %% Setup the status bar.
            hStatus.setText('Draw an ellipse to use as the initial mask.')
            
            %% Create the ellipse region.
            rgnMask = imellipse(axesPreview);
            
            %% If the user cancelled, reset.
            if isempty(rgnMask)
                % Turn off the mask time point indicator.
                set(editMaskTime, 'String', ' ')
                return    
            end % if
            
        case 'toggleMaskRectangle'
            %% Untoggle the other mask toggles.
            toggleOffList = findobj(guiContour, '-regexp', ...
                'Tag', 'toggleMask(Ellipse|Freehand|Threshold)$');
            set(toggleOffList, 'Value', 0)
            
            %% Setup the status bar.
            hStatus.setText('Draw a rectangle to use as the initial mask.')
            
            %% Create the rectangle region.
            rgnMask = imrect(axesPreview);
            
            %% If the user cancelled, reset.
            if isempty(rgnMask)
                % Turn off the mask time point indicator.
                set(editMaskTime, 'String', ' ')
                return    
            end % if
            
        case 'toggleMaskFreehand'
            %% Untoggle the other mask toggles.
            toggleOffList = findobj(guiContour, '-regexp', ...
                'Tag', 'toggleMask(Ellipse|Rectangle|Threshold)$');
            set(toggleOffList, 'Value', 0)
                        
            %% Setup the status bar.
            hStatus.setText('Draw a freehand region to use as the initial mask.')
            
            %% Create the freehand region.
            rgnMask = imfreehand(axesPreview);
            
            %% If the user cancelled, reset.
            if isempty(rgnMask)
                % Turn off the mask time point indicator.
                set(editMaskTime, 'String', ' ')
                return    
            end % if
            
        case 'toggleMaskThreshold'
            %% Untoggle the other mask toggles.
            toggleOffList = findobj(guiContour, '-regexp', ...
                'Tag', 'toggleMask(Ellipse|Rectangle|Freehand)$');
            set(toggleOffList, 'Value', 0)
                        
            %% Threhsold and create the region.
            
            
    end % switch
    
    %% Reset the drawing flag.
    setappdata(guiContour, 'isDrawing', 0)
    
    %% Set the region color.
    rgnMask.setColor([1 0 0])

    %% Set the mask time point box to the current time point.
    editTime = findobj(guiContour, 'Tag', 'editTime');
    set(editMaskTime, 'String', get(editTime, 'String'))
    
    %% Set the mask visible toggle button on.
    xtcontourCData = getappdata(guiContour, 'xtcontourCData');
    toggleMaskVisible = findobj(guiContour, 'Tag', 'toggleMaskVisible');
    set(toggleMaskVisible, ...
        'CData', xtcontourCData.MaskOn, ...
        'Value', 1)
    
    %% Get the handle for the region hggroup.
    set(rgnMask, 'DisplayName', 'Mask')
    rgnMaskHandle = findobj(axesPreview, 'DisplayName', 'Mask');
        
    %% Store the mask region and handle.
    setappdata(axesPreview, 'rgnMask', rgnMask)
    setappdata(axesPreview, 'rgnMaskHandle', rgnMaskHandle)
    
    %% Reset the status bar.
    hStatus.setText('')
end % togglemaskcallback

