%   Description: Active contour segmentation of images
%
%   <CustomTools>
%       <Menu>
%           <Item name="Contourer" icon="Matlab" tooltip="Active contour segmentation of images">
%               <Command>MatlabXT::xtcontour(%i)</Command>
%           </Item>
%       </Menu>
%   </CustomTools>
% 
%   �2013, P. Beemiller. Licensed under a Creative Commmons Attribution
%   license. Please see: http://creativecommons.org/licenses/by/3.0/

function xtcontour(xImarisID, varargin)
    % XTCONTOUR Active contour segmentation of images
    %   Detailed explanation goes here
    
    %% Parse the input.
    xtcontourParser = inputParser;
    
    addRequired(xtcontourParser, 'xImarisID', ...
        @(arg)...
        (isnumeric(arg) && rem(arg, 1) == 0) || ...
        (~isnan(str2double(arg)) && rem(str2double(arg), 1) == 0))
    
    addOptional(xtcontourParser, 'guiName', 'Active contour segmentation', @(arg)ischar(arg))
    
    parse(xtcontourParser, xImarisID, varargin{:})
    
    %% Connect to the Imaris instance.
    xImarisApp = xtconnectimaris(xImarisID);
    xDataSet = xImarisApp.GetDataSet;
    
    if isempty(xDataSet)
        return
    end % if
    
    %% Create the GUI figure.
    desktopPos = get(0, 'MonitorPositions');
    guiWidth = 560;
    guiHeight = 565;
    figPos = [...
        (desktopPos(1, 3) - guiWidth)/2, ...
        (desktopPos(1, 4) - guiHeight)/2, ...
        guiWidth, ...
        guiHeight];
    
    guiContour = figure(...
        'CloseRequestFcn', {@xtcontourerclosefcn}, ...
        'Color', 'k', ...
        'MenuBar', 'None', ...
        'Name', xtcontourParser.Results.guiName, ...
        'NumberTitle', 'Off', ...
        'Position', figPos, ...
        'Resize', 'Off', ...
        'Tag', 'guiContour');
    
    %% Load the button cdata.
    xtcontourCData = load('xtcontour_cdata.mat');
    setappdata(guiContour, 'xtcontourCData', xtcontourCData)
    
    %% Get the number of channels and assign an index to use to add the contour channel.
    cSize = xDataSet.GetSizeC;
    mIdx = cSize;

    %% Create the channel selection popup.
    % Get the Imaris channel names.    
    xChannelNames = cell(cSize, 1);
    for c = 1:cSize
        channelString = char(xDataSet.GetChannelName(c - 1));
        if strcmp(channelString, '(name not specified)')
            xChannelNames{c} = ['Channel ' num2str(c)];
            
        else
            xChannelNames{c} = char(xDataSet.GetChannelName(c - 1));
            
        end % if
    end % for c
    
    % Create the label and popup.
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', guiContour, ...
        'Position', [10 522 158 24], ...
        'String', 'Contour channel', ...
        'Style', 'text', ...
        'Tag', 'textChannel');
    
    popupChannels = uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Callback', {@popupchannelcallback, xDataSet, guiContour}, ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'Parent', guiContour, ...
        'Position', [10 498 150 24], ...
        'Style', 'popupmenu', ...
        'String', xChannelNames, ...
        'Tag', 'popupChannels', ...
        'TooltipString', 'Select a channel');
    
    % Create the refresh channels button.
    uicontrol(...
        'BackgroundColor', get(guiContour, 'Color'), ...
        'Callback', {@pushchannelrefreshcallback, xDataSet, popupChannels}, ...
        'CData', xtcontourCData.ChannelRefresh, ...
        'Parent', guiContour, ...
        'Position', [166 496 24 24], ...
        'Style', 'pushbutton', ...
        'Tag', 'pushContour', ...
        'TooltipString', 'Refresh the list of Imaris channels');
    
    %% Create a preview axes.
    axesPreview = axes(...
        'Box', 'On', ...
        'Color', 'None', ...
        'NextPlot', 'Add', ...
        'Parent', guiContour, ...
        'Position', [245 83 256 256]./[guiWidth guiHeight guiWidth guiHeight], ...
        'Tag', 'axesPreview', ...
        'XTick', [], ...
        'XTickLabel', {}, ...
        'YTick', [], ...
        'YTickLabel', {});
    
    % Plot a blank image. We update the cdata later.
    imshow(zeros([256, 256], 'uint8'));
    axis image
    
    % Create appdata to store the contours.
    contourHandleList = nan(1, xDataSet.GetSizeT);
    setappdata(axesPreview, 'contourHandleList', contourHandleList)
    
    %% Create the contour parameter editing panel.
    panelContourWeights = uipanel(...
        'Background', get(guiContour, 'Color'), ...
        'BorderType', 'Line', ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'HighlightColor', 'w', ...
        'Parent', guiContour, ...
        'Position', [9 304 180 179]./[guiWidth, guiHeight, guiWidth, guiHeight], ...
        'Title', 'Contour weights', ...
        'Tag', 'panelContourWeights');
    
    % Smoothness weight
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', panelContourWeights, ...
        'Position', [10 132 110 24], ...
        'String', 'Smoothness', ...
        'Style', 'text', ...
        'Tag', 'textSmoothWeight');
    
    tipString = sprintf([...
        'Enter a smoothness weight:\n' ...
        '\tLower smoothness weights allow the contour to match more jagged region boundaries']);        
    editSmoothWeight = mycontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelContourWeights, ...
        'Position', [130 136 40 20], ...
        'Style', 'edit', ...
        'String', '1', ...
        'Tag', 'editSmoothWeight', ...
        'TooltipString', tipString);
    set(editSmoothWeight.Handle, 'Callback', {@editcontourvalidationcallback, editSmoothWeight});
    
    % Intensity weight
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', panelContourWeights, ...
        'Position', [10 90 110 24], ...
        'String', 'Intensity (xe-3)', ...
        'Style', 'text', ...
        'Tag', 'textIntensityWeight');
    
    tipString = sprintf([...
        'Enter an intensity weight:\n' ...
        '\tHigher intensity weights increase the importance of\n' ...
        '\tthe inside contour vs outside contour intensity difference']);
    editIntensityWeight = mycontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelContourWeights, ...
        'Position', [130 94 40 20], ...
        'Style', 'edit', ...
        'String', '0.1', ...
        'Tag', 'editIntensityWeight', ...
        'TooltipString', tipString);
    set(editIntensityWeight.Handle, 'Callback', {@editcontourvalidationcallback, editIntensityWeight});
    
    % Delta T
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', panelContourWeights, ...
        'Position', [10 48 110 24], ...
        'String', 'Delta T', ...
        'Style', 'text', ...
        'Tag', 'textDeltaT');
    
    tipString = sprintf([...
        'Enter a delta T value:\n' ...
        '\tHigher delta T values increase the rate at which the contour evolves,\n' ...
        '\tbut can cause the contour to evolve erratically']);
    editDeltaT = mycontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelContourWeights, ...
        'Position', [130 52 40 20], ...
        'Style', 'edit', ...
        'String', '2', ...
        'Tag', 'editDeltaT', ...
        'TooltipString', tipString);
    set(editDeltaT.Handle, 'Callback', {@editcontourvalidationcallback, editDeltaT});
    
    % Iterations
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', panelContourWeights, ...
        'Position', [10 6 110 24], ...
        'String', 'Iterations', ...
        'Style', 'text', ...
        'Tag', 'textIterations');
    
    tipString = sprintf([...
        'Enter the number of iterations to perform:\n' ...
        '\tIncrease the number of iterations if the contour fails to\n' ...
        '\tmatch the image gradients']);
    editIterations = mycontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelContourWeights, ...
        'Position', [130 10 40 20], ...
        'Style', 'edit', ...
        'String', '5', ...
        'Tag', 'editIterations', ...
        'TooltipString', tipString);
    set(editIterations.Handle, 'Callback', {@editcontourvalidationcallback, editIterations});
    
    %% Create the initial segmentation editing panel.
    panelMask = uipanel(...
        'Background', get(guiContour, 'Color'), ...
        'BorderType', 'Line', ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'HighlightColor', 'w', ...
        'Parent', guiContour, ...
        'Position', [9 194 180 95]./[guiWidth, guiHeight, guiWidth, guiHeight], ...
        'Title', 'Initial segmentation', ...
        'Tag', 'panelMask');
    
    % Edit box to display the time point to use for the initial mask--not
    % user editable.
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', panelMask, ...
        'Position', [10 48 110 24], ...
        'String', 'Time point', ...
        'Style', 'text', ...
        'Tag', 'textMaskTime');
    
    editMaskTime = uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Enable', 'Inactive', ...
        'FontSize', 10, ...
        'Foreground', 'r', ...
        'Parent', panelMask, ...
        'Position', [130 52 40 20], ...
        'Style', 'edit', ...
        'String', ' ', ...
        'Tag', 'editMaskTime', ...
        'TooltipString', 'Initial time point to contour');
    
    % Buttons to create the initial mask. All buttons share the same
    % callback.
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'BusyAction', 'Cancel', ...
        'Callback', {@togglemaskcallback, axesPreview, guiContour}, ...
        'CData', xtcontourCData.MaskEllipse, ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelMask, ...
        'Position', [10 10 24 24], ...
        'Style', 'togglebutton', ...
        'String', '', ...
        'Tag', 'toggleMaskEllipse', ...
        'TooltipString', 'Draw an ellipse to use as an initial mask');
    
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'BusyAction', 'Cancel', ...
        'Callback', {@togglemaskcallback, axesPreview, guiContour}, ...
        'CData', xtcontourCData.MaskRectangle, ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelMask, ...
        'Position', [40 10 24 24], ...
        'Style', 'togglebutton', ...
        'String', '', ...
        'Tag', 'toggleMaskRectangle', ...
        'TooltipString', 'Draw a rectangle to use as an initial mask');
    
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'BusyAction', 'Cancel', ...
        'Callback', {@togglemaskcallback, axesPreview, guiContour}, ...
        'CData', xtcontourCData.MaskFreehand, ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelMask, ...
        'Position', [70 10 24 24], ...
        'Style', 'togglebutton', ...
        'String', '', ...
        'Tag', 'toggleMaskFreehand', ...
        'TooltipString', 'Draw a freehand region to use as an initial mask');
    
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'BusyAction', 'Cancel', ...
        'Callback', {@togglemaskcallback, axesPreview, guiContour}, ...
        'CData', xtcontourCData.MaskThreshold, ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelMask, ...
        'Position', [100 10 24 24], ...
        'Style', 'togglebutton', ...
        'String', '', ...
        'Tag', 'toggleMaskThreshold', ...
        'TooltipString', 'Use a threshold to create an initial mask');
    
    % Button to toggle the mask visibility.
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'BusyAction', 'Cancel', ...
        'Callback', {@togglemaskvisiblecallback, axesPreview, guiContour}, ...
        'CData', xtcontourCData.MaskOff, ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelMask, ...
        'Position', [146 10 24 24], ...
        'Style', 'togglebutton', ...
        'String', '', ...
        'Tag', 'toggleMaskVisible', ...
        'TooltipString', 'Show or hide the initial mask');
    
    %% Create the filter parameter editing panel.
    panelFilterParameters = uipanel(...
        'Background', get(guiContour, 'Color'), ...
        'BorderType', 'Line', ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'HighlightColor', 'w', ...
        'Parent', guiContour, ...
        'Position', [9 42 180 137]./[guiWidth, guiHeight, guiWidth, guiHeight], ...
        'Title', 'Filter parameters', ...
        'Tag', 'panelFilterParameters');
    
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', panelFilterParameters, ...
        'Position', [10 90 110 24], ...
        'String', 'Sigma', ...
        'Style', 'text', ...
        'Tag', 'textSigma');
    
    editSigma = mycontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelFilterParameters, ...
        'Position', [130 94 40 20], ...
        'Style', 'edit', ...
        'String', '10', ...
        'Tag', 'editSigma', ...
        'TooltipString', 'Enter a standard deviation');
    set(editSigma.Handle, 'Callback', {@editfiltervalidationcallback, editSigma, guiContour});
   
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', panelFilterParameters, ...
        'Position', [10 48 110 24], ...
        'String', 'Offset', ...
        'Style', 'text', ...
        'Tag', 'textOffset');
    
    editOffset = mycontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Callback', {@editsmoothnesscallback, guiContour}, ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelFilterParameters, ...
        'Position', [130 52 40 20], ...
        'Style', 'edit', ...
        'String', '0.5', ...
        'Tag', 'editOffset', ...
        'TooltipString', 'Enter an offset');
    set(editOffset.Handle, 'Callback', {@editfiltervalidationcallback, editOffset, guiContour});

    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'HorizontalAlign', 'Left', ...
        'Parent', panelFilterParameters, ...
        'Position', [10 6 110 24], ...
        'String', 'Scale factor', ...
        'Style', 'text', ...
        'Tag', 'textScaleFactor');
    
    editScaleFactor = mycontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Callback', {@editintensitycallback, guiContour}, ...
        'FontSize', 10, ...
        'Foreground', 'w', ...
        'Parent', panelFilterParameters, ...
        'Position', [130 10 40 20], ...
        'Style', 'edit', ...
        'String', '1.5', ...
        'Tag', 'editScaleFactor', ...
        'TooltipString', 'Enter a scale factor');
    set(editScaleFactor.Handle, 'Callback', {@editfiltervalidationcallback, editScaleFactor, guiContour});
    
    %% Create a histogram axes with lines to adjust the contrast limits.
    axesHistogram = axes(...
        'Box', 'On', ...
        'Color', 'None', ...
        'NextPlot', 'Add', ...
        'Parent', guiContour, ...
        'Position', [245 349 256 32]./[guiWidth guiHeight guiWidth guiHeight], ...
        'Tag', 'axesHistogram', ...
        'XColor', 'w', ...
        'XTick', [], ...
        'XTickLabel', {}, ...
        'YColor', 'w', ...
        'YTick', [], ...
        'YTickLabel', {});
    
    %% Create a blank histogram plot.
    barHistogram = bar(axesHistogram, 0:1, zeros(1, 2), ...
        'EdgeColor', [0.5 0.5 0.5], ...
        'FaceColor', [0.5 0.5 0.5], ...
        'Tag', 'barHistogram');
    uistack(barHistogram, 'bottom')
    set(axesHistogram, 'XLim', [0 1], 'YLim', [0 1.2]);
    
    %% Create the limit scaling lines to use as sliders.
    lineLowCLim = line([0, 0], [0 1.3], ...
        'Color', 'r', ...
        'LineWidth', 2', ...
        'Parent', axesHistogram, ...
        'Tag', 'lineLowCLim');
    set(lineLowCLim, 'ButtonDownFcn', {@startlowdragfcn, editMaskTime, axesHistogram, axesPreview, guiContour})

    lineHighCLim = line([1, 1], [0 1.3], ...
        'Color', 'g', ...
        'LineWidth', 2', ...
        'Parent', axesHistogram, ...
        'Tag', 'lineHighCLim');
    set(lineHighCLim, 'ButtonDownFcn', {@starthighdragfcn, editMaskTime, axesHistogram, axesPreview, guiContour})

    % Set the figure button up function to deactivate dragging.
    set(guiContour, 'WindowButtonUpFcn', {@stopdragfcn})
    
    %% Create axes interaction buttons.
    % Toggle zoom
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Callback', {@togglezoomcallback, guiContour}, ...
        'CData', xtcontourCData.Zoom, ...
        'Parent', guiContour, ...
        'Position', [215 316 24 24], ...
        'String', '', ...
        'Style', 'togglebutton', ...
        'Tag', 'toggleZoom', ...
        'TooltipString', 'Zoom');
    
    % Toggle pan
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Callback', {@togglepancallback, guiContour}, ...
        'CData', xtcontourCData.Pan, ...
        'Parent', guiContour, ...
        'Position', [215 286 24 24], ...
        'String', '', ...
        'Style', 'togglebutton', ...
        'Tag', 'togglePan', ...
        'TooltipString', 'Pan');
    
    % Toggle data cursor
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Callback', {@toggledatacursorcallback, guiContour}, ...
        'CData', xtcontourCData.DataCursor, ...
        'Parent', guiContour, ...
        'Position', [215 256 24 24], ...
        'String', '', ...
        'Style', 'togglebutton', ...
        'Tag', 'toggleDataCursor', ...
        'TooltipString', 'Data cursor');
    
    % Toggle cropping
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Callback', {@togglecropcallback, axesPreview, guiContour}, ...
        'CData', xtcontourCData.CropOff, ...
        'Parent', guiContour, ...
        'Position', [215 226 24 24], ...
        'String', '', ...
        'Style', 'togglebutton', ...
        'Tag', 'toggleCrop', ...
        'TooltipString', 'Limit the active contour region');
    
    % Toggle filtering
    uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Callback', {@togglefiltercallback, editMaskTime, axesPreview, guiContour}, ...
        'CData', xtcontourCData.FilterOff, ...
        'Parent', guiContour, ...
        'Position', [215 196 24 24], ...
        'String', '', ...
        'Style', 'togglebutton', ...
        'Tag', 'toggleFilter', ...
        'TooltipString', 'Filter the image with a high-k emphasis filter');
    
    %% Create a play button, time point slider and frame edit box for the preview axes.
    % Toggle play
    togglePlay = uicontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Callback', {@toggleplaycallback, guiContour}, ...
        'CData', xtcontourCData.Play, ...
        'Enable', 'Inactive', ...
        'Parent', guiContour, ...
        'Position', [210 42 24 24], ...
        'Style', 'togglebutton', ...
        'Tag', 'togglePlay', ...
        'TooltipString', 'Play');
    
    % Time point slider
    sliderTime = uicomponent(...
        'Background', java.awt.Color.black, ...
        'Foreground', java.awt.Color.white, ...
        'KeyReleasedCallback', {@slidertimecallback, editMaskTime, axesPreview, guiContour}, ...
        'Minimum', 1, ...
        'Maximum', 1, ...
        'MouseReleasedCallback', {@slidertimecallback, editMaskTime, axesPreview, guiContour}, ...
        'Name', 'sliderTime', ...
        'PaintTicks', 1, ...
        'Parent', guiContour, ...
        'Position', [238, 38, 260, 24], ...
        'Style', 'javax.swing.jslider', ...
        'ToolTipText', num2str(1, '%u'), ...
        'Value', 1);
    
    % Time point edit box.
    editTime = mycontrol(...
        'Background', get(guiContour, 'Color'), ...
        'Enable', 'Inactive', ...
        'FontSize', 12, ...
        'Foreground', 'w', ...
        'Parent', guiContour, ...
        'Position', [502 42 48 24], ...
        'Style', 'edit', ...
        'String', '1', ...
        'Tag', 'editTime', ...
        'TooltipString', 'Enter a time point');
    set(editTime.Handle, 'Callback', ...
        {@edittimecallback, editTime, sliderTime, editMaskTime, axesPreview, guiContour})
    
    % Create a timer function for the play button.
    timerPlay = timer(...
        'BusyMode', 'drop', ...
        'ExecutionMode', 'fixedSpacing', ...
        'Name', 'timerPlay', ...
        'Period', 0.042, ... % 1/24
        'Tag', 'timerPlay', ...
        'TimerFcn', {@timerplaycallback, sliderTime, editTime.Handle, editMaskTime, axesPreview, guiContour});
    setappdata(togglePlay, 'timerPlay', timerPlay)
    
    %% Create a button to perform the contouring and to export the data to Imaris.
    uicontrol(...
        'BackgroundColor', get(guiContour, 'Color'), ...
        'Callback', {@pushcontourcallback, editMaskTime, axesPreview, guiContour}, ...
        'CData', xtcontourCData.Contour, ...
        'Parent', guiContour, ...
        'Position', [507 316 24 24], ...
        'Style', 'pushbutton', ...
        'Tag', 'pushContour', ...
        'TooltipString', 'Contour the initial time point');
    
    uicontrol(...
        'BackgroundColor', get(guiContour, 'Color'), ...
        'Callback', {@pushcontourallcallback, editMaskTime, axesPreview, guiContour}, ...
        'CData', xtcontourCData.ContourAll, ...
        'Parent', guiContour, ...
        'Position', [507 286 24 24], ...
        'Style', 'pushbutton', ...
        'Tag', 'pushContour', ...
        'TooltipString', 'Contour all time points');
    
    uicontrol(...
        'BackgroundColor', get(guiContour, 'Color'), ...
        'Callback', {@pushexportcallback, xImarisApp, mIdx, axesPreview, guiContour}, ...
        'CData', xtcontourCData.Export, ...
        'Parent', guiContour, ...
        'Position', [507 256 24 24], ...
        'Style', 'pushbutton', ...
        'Tag', 'pushContour', ...
        'TooltipString', 'Export the data to Imaris');
    
    %% Setup the status bar.
    hStatus = statusbar(guiContour, '');
    hStatus.CornerGrip.setVisible(false)
    
    hStatus.ProgressBar.setForeground(java.awt.Color.black)
    hStatus.ProgressBar.setString('')
    hStatus.ProgressBar.setStringPainted(true)
end % xtcountour


%% Callback functions to handle contrast limit adjustments.
function startlowdragfcn(hLine, ~, editMaskTime, axesHistogram, axesPreview, guiContour)
    % STARTLOWDRAGFCN Activate dragging of the low contrast limit
    %
    %
    
    %% Set the window drag function.
    set(guiContour, 'WindowButtonMotionFcn', {@draglowfcn, hLine, editMaskTime, axesHistogram, axesPreview})
end % startlowdragfcn


function starthighdragfcn(hLine, ~, editMaskTime, axesHistogram, axesPreview, guiContour)
    % STARTHIGHDRAGFCN Activate dragging of the high contrast limit
    %
    %
    
    %% Set the window drag function.
    set(guiContour, 'WindowButtonMotionFcn', {@draghighfcn, hLine, editMaskTime, axesHistogram, axesPreview})
end % starthighdragfcn


function draglowfcn(guiContour, ~, hLine, editMaskTime, axesHistogram, axesPreview)
    % DRAGLOWFCN Get the low contrast limit value
    %
    %
    
    %% Get the value of the current point.
    dragPoint = get(axesHistogram, 'CurrentPoint');
    lowCLim = dragPoint(1, 1);

    %% Get the data range.
    dataRange = get(axesHistogram, 'XLim');
    
    %% Get the high clim line position.
    lineHighCLim = findobj(axesHistogram, 'Tag', 'lineHighCLim');
    highXs = get(lineHighCLim, 'XData');
    highCLim = highXs(1);
    
    %% Check for an out of bounds value, then update.
    if lowCLim > dataRange(1) && lowCLim < highCLim
        % Update the line.
        set(hLine, 'XData', dragPoint(1, 1)*[1 1])

        % Adjust the preview axes clims.
        set(axesPreview, 'CLim', [lowCLim highCLim])
    end % if

    %% Call the preview update function.
    updatepreview(editMaskTime, axesPreview, guiContour)
end % draglowfcn


function draghighfcn(guiContour, ~, hLine, editMaskTime, axesHistogram, axesPreview)
    % DRAGHIGHFCN Get the low contrast limit value
    %
    %
    
    %% Get the current point.
    dragPoint = get(axesHistogram, 'CurrentPoint');
    highCLim = dragPoint(1, 1);

    %% Get the data range.
    dataRange = get(axesHistogram, 'XLim');
    
    %% Get the low clim line position.
    lineLowCLim = findobj(axesHistogram, 'Tag', 'lineLowCLim');
    lowXs = get(lineLowCLim, 'XData');
    lowCLim = lowXs(1);

    % Check for an out of bounds value.
    if highCLim < dataRange(2) && highCLim > lowCLim
        % Update the line.
        set(hLine, 'XData', dragPoint(1, 1)*[1 1])

        % Adjust the preview axes clims.
        set(axesPreview, 'CLim', [lowCLim highCLim])
    end % if

    %% Call the preview update function.
    updatepreview(editMaskTime, axesPreview, guiContour)
end % draghighfcn


function stopdragfcn(guiContour, ~)
    % STOPDRAGFCN Deactivate dragging on button up
    %
    %
    
    %% Reset the window motion function.
    set(guiContour, 'WindowButtonMotionFcn', '')
end % stopdragfcn


%% Callback function to validate contour parameter editbox changes
function editcontourvalidationcallback(hObject, ~, hObjectContainer)
    % EDITCONTOURVALIDATIONCALLBACK Verify the contour parameters
    %
    %

    %% Update the editbox value if the input is numeric.
    newValue = str2double(get(hObject, 'String'));

    if isnan(newValue) || newValue < 0
        % Restore the previous good value.
        set(hObject, 'String', hObjectContainer.OldString)

    else
        % Update the value.
        set(hObject, 'String', newValue)
        hObjectContainer.OldString = newValue;
        
    end % if
end % editcontourvalidationcallback


%% Callback function to validate filter parameter editbox changes
function editfiltervalidationcallback(hObject, ~, hObjectContainer, guiContour)
    % EDITFILTERVALIDATIONCALLBACK Verify the filter settings
    %
    %

    %% Update the editbox value if the input is numeric.
    newValue = str2double(get(hObject, 'String'));

    if isnan(newValue) || newValue < 0
        % Restore the previous good value.
        set(hObject, 'String', hObjectContainer.OldString)

    else
        % Update the value.
        set(hObject, 'String', newValue)
        hObjectContainer.OldString = newValue;
        
        % If the filter button is activated, call the filter function.
        toggleFilter = findobj(guiContour, 'Tag', 'toggleFilter');
        
        if get(toggleFilter, 'Value') == 1
            axesPreview = findobj(guiContour, 'Tag', 'axesPreview');
            togglefiltercallback(toggleFilter, [], axesPreview, guiContour)
        end % if

    end % if
end % editfiltervalidationcallback


%% GUI close request function
function xtcontourerclosefcn(guiContour, ~)
    % XTCONTOURERCLOSEFCN Close the gui
    %
    %
    
    %% Close the region position window if open.
    guiRegionPos = getappdata(guiContour, 'guiRegionPos');
    if ~isempty(guiRegionPos)
        delete(guiRegionPos)
    end % if
    
    %% Find the play button timer object, stop it, delete it, then close the GUI.
    togglePlay = findobj(guiContour, 'Tag', 'togglePlay');
    timerPlay = getappdata(togglePlay, 'timerPlay');
    
    stop(timerPlay)
    delete(timerPlay)
    delete(guiContour)
end % xtndnderizerclosefcn