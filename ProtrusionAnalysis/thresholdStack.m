function [ BWStack ] = thresholdStack( fileStack,varargin )
%thresholdStack Used to threshold an intensity image into a binary
% 'fileStack' is the array to be thresholded  
% 'median' changes the method from im2bw to calculating the median  
%  varagin 3 will equal the multiplier for the median threshold 
%   
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

%%
% Check that the number of arguments in is between 1 and 3
narginchk(1,3);
% find the size of the stack to to be threshold
dimensions = size(fileStack);
if length(dimensions) == 2
    dimensions(3) = 1;
end
% Assign the multiplied to 1
mult = 1;
% Switch based on the # of arguments in
switch nargin
    case 1 % Use the im2bw method from Matlab
        BWStack = zeros(dimensions,'uint8');
        for ii = 1:dimensions(3)
            level = graythresh(fileStack(:,:,ii));
            BWStack(:,:,ii) = im2bw(fileStack(:,:,ii),level);
        end % for
        
    case 2 % Use the frame median as the threshold
        if strcmp(varargin{1},'median') == 1;
            BWStack = zeros(dimensions,'uint8');
            for ii = 1:dimensions(3)
                med = median(reshape(fileStack(:,:,ii),1,dimensions(1)*dimensions(2)));
                tempZeros = zeros(dimensions(1),dimensions(2),'uint8');
                tempZeros(fileStack(:,:,ii) > med*mult) = 1;
                BWStack(:,:,ii) = tempZeros;
            end % for
        else 
            errordlg('Unidentifiable threshold method. Currently, "median" is allowed');
            return
        end % if
    case 3 % Use the frame median times a multiplier as the threshold
        if strcmp(varargin{1},'median') && isa(varargin{2},'numeric')
            mult = varargin{2};
            BWStack = zeros(dimensions,'uint8');
            for ii = 1:dimensions(3)                
                med = median(reshape(fileStack(:,:,ii),1,dimensions(1)*dimensions(2)));
                tempZeros = zeros(dimensions(1),dimensions(2),'uint8');
                tempZeros(fileStack(:,:,ii) > med*mult) = 1;
                BWStack(:,:,ii) = tempZeros;
            end % for
        else
            errordlg('Either method or multiplier is not allowed');
            return
        end % if      
end % switch

end % thresholdStack

