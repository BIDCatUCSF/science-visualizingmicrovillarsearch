function [ mask,fillStack ] = mask(binaryStack,guiPA)
%MASK This function is used to create the mask to isolate the protrusions
%from the edges of the cell. R2015b
% 
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017
    
    %% 
    structParameters = getappdata(guiPA,'structParameters');
    shrinkExtent = structParameters.shrinkExtent;

    dimensions = size(binaryStack);
    c = class(binaryStack);

    % Thicken the B&W stack to smooth the edges
    thickStack = zeros(dimensions,c);
    for ii = 1:dimensions(3);
        thickStack(:,:,ii) = bwmorph(binaryStack(:,:,ii),'thicken',1);
    end % for
    
    % Close the thick stack to round out protrusions.
    closeStack = zeros(dimensions,c);
    for ii = 1:dimensions(3);
        closeStack(:,:,ii) = bwmorph(thickStack(:,:,ii),'close');
    end % for
    
    % Fill the stack to get rid of any holes or lines 
    fillStack = zeros(dimensions,c);
    for ii = 1:dimensions(3);
        fillStack(:,:,ii) = imfill(closeStack(:,:,ii),'holes');
    end % for
    
    % Shrink the stack to a size that falls within the cell edges
    shrinkStack = zeros(dimensions,c);
    for ii = 1:dimensions(3);
        shrinkStack(:,:,ii) = bwmorph(fillStack(:,:,ii),'shrink',shrinkExtent);
    end % for
    
    % Create the final mask. The mask is made from the shrink stack and has to
    % be positive through the entire stack.
    mask = zeros(dimensions(1),dimensions(2),1,c);
    for xx = 1:dimensions(2)
        for yy = 1:dimensions(1)
            for ii = 1:dimensions(3)
                temp = sum(shrinkStack(yy,xx,1:ii));
                if temp == dimensions(3)
                    mask(yy,xx) = 1;
                end % if
            end % for
        end % for
    end % for
    
end % mask

