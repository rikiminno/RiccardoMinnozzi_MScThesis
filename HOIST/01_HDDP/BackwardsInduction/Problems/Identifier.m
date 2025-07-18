classdef Identifier
    % basic class defining the identifier for a problem-related quantity
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (GetAccess = public, SetAccess = protected)
        ID (3, 1) {mustBeVector(ID)} = [-1; -1; -1] %[k, i, p]
    end

    methods
        function obj = Identifier(ID)
            % IDENTIFIER constructor

            if nargin > 0
                obj.ID  = ID;
            end
        end

        function ID = getID(obj)
            % function to retrieve the problem ID

            ID  = obj.ID;
        end

        function [obj] = setID(obj, newID)
            % function to update the object idenfier

            for i = 1:length(obj)
                obj(i).ID = newID;
            end
        end

    end
end

