function waveColor = stringtocolor(colorString)
    % STRINGTOCOLOR Map a string color identifier to an RGB color
    %
    %   Syntax
    %   ------
    %   waveColor = STRINGTOCOLOR(waveString) attempts to determine the
    %   color that corresponds to the string 'waveString'. The output
    %   waveColor is an RGB triplet.
    %
    %   Examples
    %   --------
    %   waveColor = stringtocolor('Red') % Returns [1 0 0]
    %   waveColor = stringtocolor('Green channel') % Returns [0 1 0]
    %
    %   Notes
    %   -----
    %   In addition to creating RGB triplets for color names, stringtocolor
    %   searches for various common fluorophore names from cell biology,
    %   such as 'GFP', and converts them to a reasonable matching color
    %   triplet, e.g., [0 1 0] in the case of GFP (Green Fluorescent
    %   Protein).
    %   
    %   ©2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    
    
    waveColor = regexp(colorString, ...
        ['Red|Green|Blue|Yellow|Cyan|Magenta|Purple|Orange|' ...
        'CFP|GFP|RFP|YFP|Cherry|Tomato|TagRFP|' ...
        'DAPI|Fura 340|Fura 380|QDot'], ...
        'Match', 'Once', 'IgnoreCase');

    switch lower(waveColor)

        case {'red', 'rfp'}
            waveColor = rgbtripleto24bit(1, 0, 0);

        case {'green', 'gfp'}
            waveColor = rgbtripleto24bit(0, 1, 0);

        case {'blue', 'dapi'}
            waveColor = rgbtripleto24bit(0, 0, 1);

        case {'yellow', 'yfp'}
            waveColor = rgbtripleto24bit(1, 1, 0);

        case {'cyan', 'cfp', 'fura 380'}
            waveColor = rgbtripleto24bit(0, 1, 1);

        case {'magenta', 'purple', 'fura 340', 'qdot'}
            waveColor = rgbtripleto24bit(1, 0, 1);

        case {'orange', 'cherry', 'tomato', 'tagrfp'}
            waveColor = rgbtripleto24bit(1, 0.5, 0);
        
        otherwise
            waveColor = rgbtripleto24bit(1, 1, 1);

    end % switch
    
end % wavestringtocolor

