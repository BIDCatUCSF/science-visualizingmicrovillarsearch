function regionpositiongui(rgnCrop, hParent)
    % REGIONPOSITIONGUI Manually set region of interest position
    %   Detailed explanation goes here
    
    %% Check for an existing setting window.
    guiRegionPos = getappdata(hParent, 'guiRegionPos');
    
    if ~isempty(guiRegionPos)
        figure(guiRegionPos)
        return
    end % if
    
    %% Get the parent figure's position.
    parentPos = get(hParent, 'Position');
    guiWidth = 229;
    guiHeight = 113;
    guiPos = [...
        parentPos(1) + 767 ...
        parentPos(2) guiWidth guiHeight];
    
    %% Create a figure to manually edit the object position.
    guiRegionPos = figure(...
        'CloseRequestFcn', {@closerequestfcn, rgnCrop, hParent}, ...
        'Color', 'k', ...
        'DockControls', 'off', ...
        'MenuBar', 'None', ...
        'Name', 'Set region location', ...
        'NumberTitle', 'Off', ...
        'Position', guiPos, ...
        'Resize', 'off', ...
        'Tag', 'guiRegionPos');

    %% Create the position editing controls.
    % Get the object's current position.
    rgnPos = rgnCrop.getPosition;
    
    % Get the image dimensions.
    axesPreview = findobj(hParent, 'Tag', 'axesPreview');
    imageSize = size(getimage(axesPreview));
    
    % X
    uicontrol(...
        'Background', 'k', ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', guiRegionPos, ...
        'Position', [10 68 60 24], ...
        'String', 'X', ...
        'Style', 'text', ...
        'Tag', 'textXPos');

    editXPos = uicontrol(...
        'Background', 'k', ...
        'Callback', {@editposcallback, rgnCrop, imageSize}, ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'KeyPressFcn', {@editposkeypress, rgnCrop, imageSize}, ...
        'Parent', guiRegionPos, ...
        'Position', [35 70 60 24], ...
        'String', floor(rgnPos(1)), ...
        'Style', 'edit', ...
        'Tag', 'editXPos');
        
    
    % Y
    uicontrol(...
        'Background', 'k', ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', guiRegionPos, ...
        'Position', [10 18 60 24], ...
        'String', 'Y', ...
        'Style', 'text', ...
        'Tag', 'textYPos');

    editYPos = uicontrol(...
        'Background', 'k', ...
        'Callback', {@editposcallback, rgnCrop, imageSize}, ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'KeyPressFcn', {@editposkeypress, rgnCrop, imageSize}, ...
        'Parent', guiRegionPos, ...
        'Position', [35 20 60 24], ...
        'String', floor(rgnPos(2)), ...
        'Style', 'edit', ...
        'Tag', 'editYPos');
        
    % Width
    uicontrol(...
        'Background', 'k', ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', guiRegionPos, ...
        'Position', [105 68 60 24], ...
        'String', 'Width', ...
        'Style', 'text', ...
        'Tag', 'textWidth');

    editWidth = uicontrol(...
        'Background', 'k', ...
        'Callback', {@editposcallback, rgnCrop, imageSize}, ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'KeyPressFcn', {@editposkeypress, rgnCrop, imageSize}, ...
        'Parent', guiRegionPos, ...
        'Position', [159 70 60 24], ...
        'String', floor(rgnPos(3)), ...
        'Style', 'edit', ...
        'Tag', 'editWidth');
    uistack(editWidth, 'up', 1)
    
    % Height
    uicontrol(...
        'Background', 'k', ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', guiRegionPos, ...
        'Position', [105 18 60 24], ...
        'String', 'Height', ...
        'Style', 'text', ...
        'Tag', 'textHeight');

    editHeight = uicontrol(...
        'Background', 'k', ...
        'Callback', {@editposcallback, rgnCrop, imageSize}, ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'KeyPressFcn', {@editposkeypress, rgnCrop, imageSize}, ...
        'Parent', guiRegionPos, ...
        'Position', [159 20 60 24], ...
        'String', floor(rgnPos(4)), ...
        'Style', 'edit', ...
        'Tag', 'editHeight');
        
    %% Add a new position callback to the obj to update the GUI on drag.
    rgnCrop.UpdateGUIPositionCallback = rgnCrop.addNewPositionCallback(...
        @(rgnPos)updateposgui(rgnPos, editXPos, editYPos, editWidth, editHeight));
    
    %% Store the figure handle as appdata in the parent GUI.
    setappdata(hParent, 'guiRegionPos', guiRegionPos)
end % regionpositiongui


%% Callback for position editbox elements
function editposcallback(hEdit, ~, rgnCrop, imageSize)
    % EDITPOSCALLBACK Change the region x position
    %
    %
    
    %% Get the string and convert to numeric.
    newValue = str2double(get(hEdit, 'String'));
    
    %% Get the region's current position.
    currentPos = rgnCrop.getPosition;

    %% Check for a valid entry.
    switch get(hEdit, 'Tag')
        
        case 'editXPos'
            if isnan(newValue) || newValue < 0 || newValue + currentPos(3) > imageSize(2)
                % Reset the edit string to the current position.
                set(hEdit, 'String', floor(currentPos(1)));
                
            else
                % Update the region position.
                newPos = currentPos;
                newPos(1) = floor(newValue) + 0.5;
                rgnCrop.setPosition(newPos)
                
            end % if
            
        case 'editYPos'
            if isnan(newValue) || newValue < 0 || newValue + currentPos(4) > imageSize(1)
                % Reset the edit string to the current position.
                set(hEdit, 'String', floor(currentPos(2)));
                
            else
                % Update the region position.
                newPos = currentPos;
                newPos(2) = floor(newValue) + 0.5;
                rgnCrop.setPosition(newPos)
                
             end % if
                        
        case 'editWidth'
            if isnan(newValue) || newValue < 0 || newValue > imageSize(2)
                % Reset the edit string to the current position.
                set(hEdit, 'String', floor(currentPos(3)));
                
            else
                % Update the region position.
                newPos = currentPos;
                newPos(3) = newValue;
                rgnCrop.setPosition(newPos)
                    
             end % if
            
        case 'editHeight'
            if isnan(newValue) || newValue < 0 || newValue > imageSize(1)
                % Reset the edit string to the current position.
                set(hEdit, 'String', floor(currentPos(4)));
                
            else
                % Update the region position.
                newPos = currentPos;
                newPos(4) = newValue;
                rgnCrop.setPosition(newPos)               
    
             end % if
            
    end % switch   
end % editposcallback


%% Callback for position editbox elements
function editposkeypress(hEdit, editEvent, rgnCrop, imageSize)
    % EDITPOSKEYPRESS Shift the region or increment the dimensions
    %
    %
    
    %% Check for an up or down press.
    switch editEvent.Key
        
        case 'uparrow'
            editValue = str2double(get(hEdit, 'String'));
            newValue = editValue + 1;
            
        case 'downarrow'
            editValue = str2double(get(hEdit, 'String'));
            newValue = editValue - 1;
        
        otherwise
            return
            
    end % switch
    
    %% Get the region's current position.
    currentPos = rgnCrop.getPosition;

    %% Check for a valid entry.
    switch get(hEdit, 'Tag')
        
        case 'editXPos'
            if isnan(newValue) || newValue < 0 || newValue + currentPos(3) > imageSize(2)
                % Reset the edit string to the current position.
                set(hEdit, 'String', floor(currentPos(1)));
                
            else
                % Update the region position.
                newPos = currentPos;
                newPos(1) = floor(newValue) + 0.5;
                rgnCrop.setPosition(newPos)
                
            end % if
            
        case 'editYPos'
            if isnan(newValue) || newValue < 0 || newValue + currentPos(4) > imageSize(1)
                % Reset the edit string to the current position.
                set(hEdit, 'String', floor(currentPos(2)));
                
            else
                % Update the region position.
                newPos = currentPos;
                newPos(2) = floor(newValue) + 0.5;
                rgnCrop.setPosition(newPos)
                
            end % if
                        
        case 'editWidth'
            if isnan(newValue) || newValue < 0 || newValue > imageSize(2)
                % Reset the edit string to the current position.
                set(hEdit, 'String', floor(currentPos(3)));
                
            else
                % Update the region position.
                newPos = currentPos;
                newPos(3) = newValue;
                rgnCrop.setPosition(newPos)
                    
            end % if
            
        case 'editHeight'
            if isnan(newValue) || newValue < 0 || newValue > imageSize(1)
                % Reset the edit string to the current position.
                set(hEdit, 'String', floor(currentPos(4)));
                
            else
                % Update the region position.
                newPos = currentPos;
                newPos(4) = newValue;
                rgnCrop.setPosition(newPos)               
    
            end % if
            
    end % switch   
end % editposkeypress


%% NewPositionCallback for roi object to update position GUI elements
function updateposgui(rgnPos, editXPos, editYPos, editWidth, editHeight)
    % UPDATEPOSGUI Update GUI values on region drag
    %   UPDATEPOSGUI is used as a NewPositionCallback for the ROI.
    %
        
    %% Update the x, y, width and height values.
    set([editXPos, editYPos, editWidth, editHeight], ...
        {'String'}, num2cell(floor(rgnPos(:))));
end % updateposgui


%% Close request function
function closerequestfcn(guiRegionPos, ~, cropRgn, hParent)
    %
    %
    %
    
    %% Delete the object position callback,
    cropRgn.removeNewPositionCallback(cropRgn.UpdateGUIPositionCallback)
    
    %% Close the GUI and remove its appdata entry.
    rmappdata(hParent, 'guiRegionPos')
    delete(guiRegionPos)
end % closerequestfcn
    