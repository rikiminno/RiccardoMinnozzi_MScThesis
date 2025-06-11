function obj = resetPropertiesToZero(obj)
% This function sets all properties of the input class 'obj' to a zeros
% matrix of the same size as their current values.

% Get meta-class information
metaObj = metaclass(obj);

% Loop through each property of the class
for i = 1:length(metaObj.PropertyList)
    % Get the property name
    propName = metaObj.PropertyList(i).Name;

    % Check if the property is not constant and has public set access
    if ~metaObj.PropertyList(i).Constant && strcmp(metaObj.PropertyList(i).SetAccess, 'public')
        % Get the size of the current property value
        currentValue = obj.(propName);

        % If the property is numeric, reset to zeros of the same size
        if isnumeric(currentValue)
            obj.(propName) = zeros(size(currentValue));
        end
    end
end
end
