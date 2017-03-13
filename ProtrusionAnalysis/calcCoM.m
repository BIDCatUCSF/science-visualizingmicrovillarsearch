function [ centerOfMass ] = calcCoM( binaryStack )
%calcCoM Calculates the center of mass for each frame from a binary stack
%(intensity unweighted). R2015b
%
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

%%
% Find the size of the stack
dimensions = size(binaryStack);
% Prealocate memory for x and y average positions
centerOfMass = zeros(dimensions(3),2);

% Go through the stack and find all pixels above zero
for ii = 1:dimensions(3)
    count = 0;
    xList = [];
    yList = [];
    for kk = 1:dimensions(1)
        for jj = 1:dimensions(2)
            if binaryStack(kk,jj,ii) > 0
                count = count + 1;
                xList(count,1) = jj;
                yList(count,1) = kk;
            end % if
        end % for
    end % for
    
    % Save the average x and y position to array
    centerOfMass(ii,1) = uint16(sum(xList)/count);
    centerOfMass(ii,2) = uint16(sum(yList)/count);


end % for

end % calcCoM

