function pushchannelrefreshcallback(~, ~, xDataSet, popupChannels)
    % PUSHCHANNELREFRESHCALLBACK Refresh the Imaris channel list
    %   Detailed explanation goes here
    
    %% Get the number of channels and assign an index to use to add the contour channel.
    cSize = xDataSet.GetSizeC;
    mIdx = cSize;

    %% Update the channel popup.
    % Get the Imaris channel names.    
    imarisChannels = cell(cSize, 1);
    for c = 1:cSize
        channelString = char(xDataSet.GetChannelName(c - 1));
        if strcmp(channelString, '(name not specified)')
            imarisChannels{c} = ['Channel ' num2str(c)];
            
        else
            imarisChannels{c} = char(xDataSet.GetChannelName(c - 1));
            
        end % if
    end % for c
    
    %% Get the currently selected channel name.
    popupChannelsString = get(popupChannels, 'String');
    popupChannelsValue = get(popupChannels, 'Value');
    popupString = popupChannelsString{popupChannelsValue};
    
    %% Try to update the selected value to match the previous value.
    newValue = find(strcmp(imarisChannels, popupString));
    
    if newValue
        set(popupChannels, 'Value', newValue)
    end % if        
end % pushchannelrefreshcallback

