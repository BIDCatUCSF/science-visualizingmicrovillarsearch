function writeTiff(array, fileName )
%writeTiff Kyle Marchuk, November 2016
%   this function writes data (in array form) to .tif format matching most
%   types. R2015b
%
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

%% create a Tiff object with fileName
outTiff = Tiff(fileName, 'w');

% Find the dimensions of the array, and give it a 1 for the third dimension
% if an initial 2D array
dimensions = size(array);
if length(dimensions) == 2
    dimensions(3) = 1;
end % if

% Set image properties within a structure
tagstruct.ImageLength = dimensions(1);
tagstruct.ImageWidth = dimensions(2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.SamplesPerPixel = 1;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
% Set properties pertinent to incoming data type
if isa(array, 'single')
    tagstruct.BitsPerSample = 32;
    tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
elseif isa(array, 'double');
    array = cast(array,'single');
    tagstruct.BitsPerSample = 32;
    tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
elseif isa(array, 'uint8');
    tagstruct.BitsPerSample = 8;
    tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
elseif isa(array, 'uint16');
    tagstruct.BitsPerSample = 16;
    tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
elseif isa(array, 'uint32');
    tagstruct.BitsPerSample = 32;
    tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
elseif isa(array, 'logical');
    tagstruct.BitsPerSample = 8;
    tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
end

for nn = 1:dimensions(3)
    % Assign the image tags to the file
    outTiff.setTag(tagstruct);
    % Write each frame
    outTiff.write(array(:,:,nn));
    % Write the frame to the directory
    outTiff.writeDirectory()
end % for
% Close the .tif
outTiff.close()

end % writeTiff

