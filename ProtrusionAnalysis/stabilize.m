function [stableStack] = stabilize(fileStack,centerOfMass)
%stabilize Function used to stabilize the original image using the center
%of mass coordinates. R2015b
%
% Kyle Marchuk
% Biological Imaging Development Center at UCSF
% Archived March 2017

    %%
    % Find the type and size of stack to be stabilized
    dimensions = size(fileStack);
    c = class(fileStack);
    
    % Used to determine the size of the cropped/stabilized file
    maxX = max(centerOfMass(:,1));
    minX = min(centerOfMass(:,1));
    maxY = max(centerOfMass(:,2));
    minY = min(centerOfMass(:,2));
    
    % Find the max size of the crop allowed
    cropWidth = 2*(min([dimensions(2)-maxX,minX]));
    cropHeight = 2*(min([dimensions(1)-maxY,minY]));
    % Ensure the size is even
    cropWidth = makeeven(cropWidth);
    cropHeight = makeeven(cropHeight);
    
    % Stabilized the stack
    stableStack = zeros(cropHeight,cropWidth,dimensions(3),c);
    for ii = 1:dimensions(3)
        for kk = 1:cropHeight
            for jj = 1:cropWidth
                stableStack(kk,jj,ii) = fileStack(kk+centerOfMass(ii,2)-(cropHeight/2),jj+centerOfMass(ii,1) - (cropWidth/2),ii);
            end % for
        end % for
    end % for

end % stabilized
% This function is used to make the width and height an even number by
% subtracting 1 if it's odd
function out = makeeven(num)
    if mod(num,2) == 0
        out = num;
    else
        out = num - 1;
    end % if
end % makeeven


