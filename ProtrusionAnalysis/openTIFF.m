function [ fileStack] = openTIFF( pathdir, fileName )
% openTIFF Opens the desired TIFF stack and fills a 3D array. R2015b
%
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

    %% Some 'homemade' .tifs may not have a proper tag. Assigns uint16
    % automatically
    warning('off', 'all'); % To ignore unknown TIFF tag.
    % find location of the file
    fileTif = strcat(pathdir,fileName);
    
    % create a tif object and assign it
    tifObj = Tiff(fileTif,'r');
    % Find the number of frames in the stack
    nFrames = 0;
    while true
        nFrames = nFrames + 1;
        if tifObj.lastDirectory() == 1
            break;
        end % if
        tifObj.nextDirectory()
    end % while
    
    % Pull information from the object tags needed to create 3D array
    xPix = tifObj.getTag('ImageWidth');
    yPix = tifObj.getTag('ImageLength');
    sf = tifObj.getTag('SampleFormat');
    bps = tifObj.getTag('BitsPerSample');
    
    % allocate memory for speed
    fileStack = zeros(yPix,xPix,nFrames,DataType(sf,bps));
    % Read the data into array
    for ii = 1:nFrames
        tifObj.setDirectory(ii)
        fileStack(:,:,ii) = tifObj.read();
    end % for
    
end % openTIFF

% This function determines what data type is in the files to assign to the
% array
function dt = DataType(sf,bps)
switch sf % SampleFormat 1=uint, 2=int, 3=IEEEFP
    case 1
        switch bps % BitsPerSample
            case 8
                dt = 'uint8';
            case 16
                dt = 'uint16';
            case 32
                dt = 'uint32';
        end % switch bps
    case 2
        switch bps % BitsPerSample
            case 8
                dt = 'int8';
            case 16
                dt = 'int16';
            case 32
                dt = 'int32';
        end % switch bps
    case 3
        switch bps % BitsPerSample
            case 32
                dt = 'single';
            case 64
                dt = 'double';
        end % switch bps
end % switch sf
end % DataType