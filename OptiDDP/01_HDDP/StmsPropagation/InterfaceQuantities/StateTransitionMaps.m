classdef StateTransitionMaps
    % class defining the state transition maps object for a specified phase
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (SetAccess = protected, GetAccess = public)
        STM
        STT
    end

    methods
        function obj = StateTransitionMaps(STM, STT)
            % ABSTRACTSTATETRANSITIONMAPS constructor

            if nargin > 0
                obj.STM = STM;
                obj.STT = STT;
            end
        end

        function [STM, STT] = getStmsAtIndex(obj, index)
            % function to retrieve the state transition maps at
            % corresponding to a certain index

            STM = obj.STM(:, :, index);
            STT = obj.STT(:, :, :, index);
        end

    end

end

