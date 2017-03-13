classdef croprect < imrect & dynamicprops
    % CROPRECT
    %
    %
    
    properties
        
        UpdateGUIPositionCallback
        
    end % properties
    
    
    methods
        
        function obj = croprect(varargin)
            % Constructor function
            %
            %
            
            obj = obj@imrect(varargin{:});
            
            if ~isequal(size(obj), [0 0])
                % Update the region color.
                obj.setColor([0 1 1])
                
                % Find the object's context menu.
                roiPatch = findobj(obj, 'Type', 'Patch');
                contextMenu = get(roiPatch, 'UIContextMenu');
                
                % Create a menu item to apply the region color to data points
                % inside the region.
                uimenu(contextMenu, ...
                    'Callback', @(varargin)setRegionPos(obj), ...
                    'Checked', 'off', ...
                    'Label', 'Set Region Position', ...
                    'Tag', 'menuSetRegionPos');
            end % if
        end % ndnderizerrect
        
        function setRegionPos(obj)
            % setRegionPos Manually set region position
            %
            %
    
            %% Get the parent figure.
            hParent = get(get(obj, 'Parent'), 'Parent');
    
            %% Call the region positioning GUI.
            regionpositiongui(obj, hParent)
        end % setRegionPos
        
    end % methods
    
    
    events
        
        
    end % events
end % croprect