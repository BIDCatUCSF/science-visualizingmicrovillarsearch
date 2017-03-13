 function popupndcallback(popupNd, ~, guiNd)
    % POPUPNDCALLBACK Update the data for the 
    %
    %
    
    %% Untoggle the zoom, pan and cursor buttons.
    toggleZoom = findobj(guiNd, 'Tag', 'toggleZoom'); 
    togglePan = findobj(guiNd, 'Tag', 'togglePan');
    toggleDataCursor = findobj(guiNd, 'Tag', 'toggleDataCursor');
    set([toggleZoom, togglePan, toggleDataCursor], 'Value' , 0)
    zoom off
    pan off
    datacursormode off
    
    %% Get the nd selection and stored nd data.
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

    %% Store the .nd file list with the parsed data.
    setappdata(popupNd, 'ndFiles', ndFiles);
    
    %% Populate the stage positions listbox.
    listboxStage = findobj(guiNd, 'Tag', 'listboxStage');
    if size(ndData, 2) == 1
        set(listboxStage, ...
            'String', '', ...
            'Value', 1)
        
    else
        set(listboxStage, ...
            'String', {ndData.StageName}, ...
            'Value', 1)

    end % if
    
    %% Setup the channel editing features.
    guiPosition = get(guiNd, 'Position');
    
    guiWidth = guiPosition(3);
    guiHeight = guiPosition(4);

    % Load the button cdata.
    xtndnderizerCData = getappdata(guiNd, 'xtndnderizerCData');
    
    % Create or update checkbox, label, color selection and alignment editing
    % elements for each channel.
    for w = 1:length(ndData(1).WaveName)
        % If the channel elements already exist, just update the channel
        % string textbox.
        textWave = findobj(guiNd, 'Tag', ['textWave' num2str(w)]);
        if ishandle(textWave)
            % Check the Metamorph channel name. If they're different,
            % update the displayed channel name, default color, shifts and scaling.
            if ~strcmp(ndData(1).WaveName{w}, get(textWave, 'UserData'))
                % Replace the channel label.
                set(textWave, ...
                    'String', ndData(1).WaveName{w}, ...
                    'UserData', ndData(1).WaveName{w})
                
                % Update the default display color.
                defaultColor = rgb32bittotriplet(stringtocolor(ndData(1).WaveName{w}));
                pushColor = findobj(guiNd, 'Tag', ['pushColor' num2str(w)]);
                set(pushColor, 'UserData', defaultColor)
                
                % Reset the channel shifts.
                editXWave = findobj(guiNd, 'Tag', ['editXWave' num2str(w)]);
                editYWave = findobj(guiNd, 'Tag', ['editYWave' num2str(w)]);
                set([editXWave, editYWave], 'String', 0)
                
                % Reset the channel scaling.
                axesLimWave = findobj(guiNd, 'Tag', ['axesLimWave' num2str(w)]);
                limLines = findobj(axesLimWave, '-regexp', 'Tag', ['(low)|(high)LimWave' num2str(w)]);
                set(limLines, {'XData'}, {[1, 1]; [0, 0]})
                
            end % if
            
        else
            % Calculate the base y position for the elements in the GUI.
            popupNdPos = get(popupNd, 'Position');
            wBaseYPos = popupNdPos(2)- 50*(w - 1);
            
            % Create the checkbox.
            uicontrol(...
                'Background', get(guiNd, 'Color'), ...
                'Callback', {@checkwavecallback, guiNd}, ...
                'FontSize', 10, ...
                'Foreground', 'w', ...
                'HorizontalAlign', 'Left', ...
                'Position', [250 wBaseYPos - 2 30 30], ...
                'String', [], ...
                'Style', 'checkbox', ...
                'Tag', ['checkWave' num2str(w)], ...
                'TooltipString', 'Check to include channel');

            % Create the label.
            uicontrol(...
                'Background', get(guiNd, 'Color'), ...
                'ButtonDownFcn', {@textwavebuttondownfcn, guiNd}, ...
                'FontSize', 10, ...
                'Foreground', 'w', ...
                'HorizontalAlign', 'Left', ...
                'Position', [280 wBaseYPos - 10 150 30], ...
                'String', ndData(1).WaveName{w}, ...
                'Style', 'text', ...
                'Tag', ['textWave' num2str(w)], ...
                'TooltipString', 'Right click to set displayed name', ...
                'UserData', ndData(1).WaveName{w});

            % Create the color selection button.
            defaultColor = rgb32bittotriplet(stringtocolor(ndData(1).WaveName{w}));
            uicontrol(...
                'Background', get(guiNd, 'Color'), ...
                'Callback', {@pushcolorcallback, guiNd}, ...
                'CData', xtndnderizerCData.ColorWheel, ...
                'HorizontalAlign', 'Center', ...
                'Position', [424 wBaseYPos + 1 24 24], ...
                'String', '', ...
                'Style', 'pushbutton', ...
                'Tag', ['pushColor' num2str(w)], ...
                'TooltipString', 'Set the channel color', ...
                'UserData', defaultColor);
            
            % Create the alignment edit boxs.
            uicontrol(...
                'Background', get(guiNd, 'Color'), ...
                'Callback', {@editshiftcallback, guiNd}, ...
                'FontSize', 10, ...
                'Foreground', 'w', ...
                'HorizontalAlign', 'Center', ...
                'KeyPressFcn', {@editshiftkeypress, guiNd}, ...
                'Position', [470 wBaseYPos + 1 48 24], ...
                'String', '0', ...
                'Style', 'edit', ...
                'Tag', ['editXWave' num2str(w)], ...
                'TooltipString', 'Set the channel x offset');

            uicontrol(...
                'Background', get(guiNd, 'Color'), ...
                'Callback', {@editshiftcallback, guiNd}, ...
                'FontSize', 10, ...
                'Foreground', 'w', ...
                'HorizontalAlign', 'Center', ...
                'KeyPressFcn', {@editshiftkeypress, guiNd}, ...
                'Position', [540 wBaseYPos + 1 48 24], ...
                'String', '0', ...
                'Style', 'edit', ...
                'Tag', ['editYWave' num2str(w)], ...
                'TooltipString', 'Set the channel y offset');
            
            % Create the intensity climit scaling objects.
            axesLim = axes(...
                'Box', 'Off', ...
                'Color', 'None', ...
                'Position', [606 wBaseYPos + 1 100 23]./[guiWidth guiHeight guiWidth guiHeight], ...
                'Tag', ['axesLimWave' num2str(w)], ...
                'XColor', 'k', ...
                'XTick', [], ...
                'XTickLabel', {}, ...
                'YColor', 'k', ...
                'YTick', [], ...
                'YTickLabel', {});
            set(axesLim, 'Units', 'Pixels')
            xlim([-0.05, 1.05])
            line([0 1], [0 0], 'Color', 'w', 'LineWidth', 3)
            
            % Draw the limit scaling lines to use as sliders.
            hLineLow = line([0, 0], [-1 1], ...
                'Color', 'r', ...
                'LineWidth', 2', ...
                'Parent', axesLim, ...
                'Tag', ['lowLimWave' num2str(w)]);
            set(hLineLow, 'ButtonDownFcn', {@startlowdragfcn, guiNd})
            
            hLineHigh = line([1, 1], [-1 1], ...
                'Color', 'g', ...
                'LineWidth', 2', ...
                'Parent', axesLim, ...
                'Tag', ['highLimWave' num2str(w)]);
            set(hLineHigh, 'ButtonDownFcn', {@starthighdragfcn, guiNd})
        
        end % if
    end % for w
    
    %% Delete any extra channel editing features leftover from previous nd imports.
    validWaveStrings = num2str(1:length(ndData(1).WaveName));
    
    checkWaveExtras = findobj(guiNd, '-regexp', 'Tag', ['checkWave[^' validWaveStrings ']']); 
    textWaveExtras = findobj(guiNd, '-regexp', 'Tag', ['textWave[^' validWaveStrings ']']); 
    pushColorWaveExtras = findobj(guiNd, '-regexp', 'Tag', ['pushColor[^' validWaveStrings ']']);
    editShiftXWaveExtras = findobj(guiNd, '-regexp', 'Tag', ['editXWave[^' validWaveStrings ']']);
    editShiftYWaveExtras = findobj(guiNd, '-regexp', 'Tag', ['editYWave[^' validWaveStrings ']']);
    axesLimWaveExtras =  findobj(guiNd, '-regexp', 'Tag', ['axesLimWave[^' validWaveStrings ']']);
    
    delete(...
        checkWaveExtras, textWaveExtras, pushColorWaveExtras, ...
        editShiftXWaveExtras, editShiftYWaveExtras, axesLimWaveExtras)
    
    %% Update the time slider.
    sliderTime = findobj(guiNd, 'Name', 'sliderTime');
    timeIdxCount = max(cellfun(@length, ndData(1).WaveTimes));
    
    if get(sliderTime, 'Value') > timeIdxCount
        set(sliderTime, ...
            'Value', timeIdxCount, ...
            'Maximum', timeIdxCount)
    else
        set(sliderTime, ...
            'Maximum', timeIdxCount)
    end % if        
        
    %% Update the z slider.
    sliderZSlice = findobj(guiNd, 'Name', 'sliderZSlice');
    zIdxCount = ndData(1).ZCount;
    
    if zIdxCount == 1
        % Set the MultiZ flag to zero.
        setappdata(guiNd, 'isNDMultiZ', 0) 

        set(sliderZSlice, ...
            'Value', 1, ...
            'Maximum', 1)
        
    else
         % Set the MultiZ flag to zero.
        setappdata(guiNd, 'isNDMultiZ', 1)
        
        if get(sliderZSlice, 'Value') > zIdxCount
            set(sliderZSlice, ...
                'Value', zIdxCount, ...
                'Maximum', zIdxCount)
        else
            set(sliderZSlice, ...
                'Maximum', zIdxCount)
        end % if        
    end % if

    %% Create appdata to store the wavelength CLim values and normalization factor.
    climArray = [zeros(w, 1), ones(w, 1)];
    normFactor = zeros(w, 1);
    
    setappdata(guiNd, 'climArray', climArray)
    setappdata(guiNd, 'normFactor', normFactor)
    
    %% Set the figure button up function to deactivate dragging.
    set(guiNd, 'WindowButtonUpFcn', {@stopdragfcn})
    
    %% Update the preview axes.
    updatepreview(guiNd, 'Refresh', true)
end % popupndcallback


%% Callback functions to handle contrast limit adjustments.
function startlowdragfcn(hLine, ~, guiNd)
    % STARTLOWDRAGFCN Activate dragging of the low contrast limit
    %
    %
    
    %% Set the window drag function.
    set(guiNd, 'WindowButtonMotionFcn', {@draglowfcn, hLine})
end % startlowdragfcn


function starthighdragfcn(hLine, ~, guiNd)
    % STARTHIGHDRAGFCN Activate dragging of the high contrast limit
    %
    %
    
    %% Set the window drag function.
    set(guiNd, 'WindowButtonMotionFcn', {@draghighfcn, hLine})
end % starthighdragfcn


function draglowfcn(guiNd, ~, hLine)
    % DRAGLOWFCN Get the low contrast limit value
    %
    %
    
    %% Get the channel associated with the current line.
    axesLimWave = get(hLine, 'Parent');
    waveIdx = str2double(regexp(get(hLine, 'Tag'), '\d{1,}', 'Match'));
    
    % Get the current point.
    dragPoint = get(axesLimWave, 'CurrentPoint');

    % Assign the point to the low value.
    lowValue = dragPoint(1, 1);

    % Get the high clim line position.
    highLine = findobj(axesLimWave, 'Tag', ['highLimWave' num2str(waveIdx)]);
    highXs = get(highLine, 'XData');
    highValue = highXs(1);

    % Check for an out of bounds value.
    if lowValue > 0 && lowValue < highValue
        % Update the line.
        set(hLine, 'XData', dragPoint(1, 1)*[1 1])

        % Adjust the stored scaling array.
        climArray = getappdata(guiNd, 'climArray');
        climArray(waveIdx, :) = [lowValue, highValue];
        setappdata(guiNd, 'climArray', climArray)
    end % if

    %% Call the preview update function.
    updatepreview(guiNd)
end % draglowfcn


function draghighfcn(guiNd, ~, hLine)
    % DRAGHIGHFCN Get the low contrast limit value
    %
    %
    
    %% Get the channel associated with the current line.
    axesLimWave = get(hLine, 'Parent');
    waveIdx = str2double(regexp(get(hLine, 'Tag'), '\d{1,}', 'Match'));

    % Get the current point.
    dragPoint = get(axesLimWave, 'CurrentPoint');

    % Assign the point to the high value.
    highValue = dragPoint(1, 1);

    % Get the low clim line position.
    lowLine = findobj(axesLimWave, 'Tag', ['lowLimWave' num2str(waveIdx)]);
    lowXs = get(lowLine, 'XData');
    lowValue = lowXs(1);

    % Check for an out of bounds value.
    if highValue < 1 && highValue > lowValue
        % Update the line.
        set(hLine, 'XData', dragPoint(1, 1)*[1 1])

        % Adjust the stored scaling array.
        climArray = getappdata(guiNd, 'climArray');
        climArray(waveIdx, :) = [lowValue, highValue];
        setappdata(guiNd, 'climArray', climArray)
    end % if

    %% Call the preview update function.
    updatepreview(guiNd)
end % draghighfcn


function stopdragfcn(guiNd, ~)
    % STOPDRAGFCN Deactivate dragging on button up
    %
    %
    
    %% Reset the window motion function.
    set(guiNd, 'WindowButtonMotionFcn', '')
end % stopdragfcn


