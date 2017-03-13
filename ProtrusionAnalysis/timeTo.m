function [ tNum ] = timeTo( cumulativeCoverage,percent )
%timeTo Finds the time to a cumulative percent coverage. R2015b
%
% Kyle Marchuk, PhD
% Biological Imaging Development Center at UCSF
% Archived March 2017

    %%
    len = length(cumulativeCoverage(:,3));
    
    for ii = 1:len
        if cumulativeCoverage(ii,3) >= percent
            tNum = cumulativeCoverage(ii,1);
            return
        else
            tNum = NaN;
        end % if
    end % for

end % timeTo

