function [cropStack, backStack, threshStack, sumStack] = calculateCoverage(fileStack,maskBinary,fillStack)
%calculateCoverage Handles most of the coverage calculations within the
%mask ROI including the instantaneous and cumulative coverages. R2015b
% 
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

    %% Load and input parameters
    discRadius = 15;
    structuredArea = strel('disk',discRadius);
    
    dimensions = size(fillStack);
    
    
    %%
    % Subtract the local background using a tophat filter
    tophatFiltered = zeros(dimensions,'uint16');
    for ii = 1:dimensions(3)
        tophatFiltered(:,:,ii) = imtophat(fileStack(:,:,ii),structuredArea);
    end % for
    
    % Crop the background subtracted stack based on the mask
    cropStack = zeros(dimensions,'uint16');
    for ii = 1:dimensions(3)
        temp = tophatFiltered(:,:,ii);
        temp(maskBinary == 0) = 0;
        cropStack(:,:,ii) = temp;
    end % for
    
    %%
    % Creates the background stack which the standard deviation is
    % calculated from. The 'Fill_' stacks creates previously are the masks.   
    backStack = zeros(dimensions,'uint16');   
    for ii = 1:dimensions(3)
        temp = tophatFiltered(:,:,ii);
        temp(fillStack(:,:,ii) ~= 0) = 0;
        backStack(:,:,ii) = temp;
    end % for
    
    % Calculate the surface mean for each frame by summing the cropStack
    % and diving by the number of pixels that aren't zero.
    surfSum = permute(sum(sum(cropStack)),[3 2 1]);
    surfSumZero = permute(sum(sum(cropStack~=0)),[3 2 1]);
    surfMean = surfSum./surfSumZero;
    
    % Calculates the std dev for each frame excluding the zeros
    backStd = zeros(1,dimensions(3));
    for ii = 1:dimensions(3)        
        backStd(ii,1) = std2(backStack(:,:,ii)~=0);
    end % for
    % Calculates the threshold for the protrusions using the mean of the
    % cropped images + 3x std of the background
    thresh = zeros(dimensions(3),1);
    for ii = 1:dimensions(3)
        thresh(ii,1) = surfMean(ii) + (3*backStd(ii));
    end % for
    
    %%
    % Stacks for coverage calculations
    threshStack = zeros(dimensions,'uint16');
    for ii = 1:dimensions(3)
        for jj = 1:dimensions(1)
            for kk = 1:dimensions(2)
                if cropStack(jj,kk,ii) > thresh(ii,1) && maskBinary(jj,kk) > 0
                    threshStack(jj,kk,ii) = 1;
                end % if
            end % for
        end % for
    end % for
    
    % Cumulative sum stack
    sumStack = zeros(dimensions,'uint16');
    for ii = 1:dimensions(3)
        for jj = 1:dimensions(1)
            for kk = 1:dimensions(2)
                temp = sum(threshStack(jj,kk,1:ii));
                if temp >= 1
                    sumStack(jj,kk,ii) = 1;
                end % if
            end % for
        end % for
    end % for
    
    
    
   
                    
    

end % calculateCoverage

