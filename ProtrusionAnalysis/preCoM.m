function [ CoMStack ] = preCoM( binaryStack )
%preCoM This function preps the binary stack for the center of mass
%calculation. R2015b
% 
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

    %%
    dimensions = size(binaryStack);
    % Close the stack to average out protrusions
    closeStack = zeros(dimensions,'uint8');
    for ii = 1:dimensions(3);
        closeStack(:,:,ii) = bwmorph(binaryStack(:,:,ii),'close');
    end % for

    % Fill the stack to close holes
    CoMStack = zeros(dimensions,'uint8');
    for ii = 1:dimensions(3);
        CoMStack(:,:,ii) = imfill(closeStack(:,:,ii),'holes');
    end % for

end % preCoM

