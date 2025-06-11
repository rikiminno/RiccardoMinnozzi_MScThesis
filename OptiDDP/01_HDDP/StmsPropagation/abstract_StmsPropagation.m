classdef abstract_StmsPropagation
    % base class for the propagation of the state transition matrices and
    % tensors
    %
    % authored by Riccardo Minnozzi, 11/2024

    properties (Access = protected)
        settings {mustBeA(settings, 'abstract_AlgorithmConfig')} = AlgorithmConfig()
    end

    methods
        function obj = abstract_StmsPropagation(settings)
            %ABSTRACT_STMSPROPAGATION constructor an instance of this class

            if nargin > 0
                obj.settings = settings;
            end
        end
    end

    methods (Static)

        function setAuxData(data)
            % function that sets the global auxiliary data variable inside
            % each parallel worker

            global auxdata
            auxdata = data;
        end

    end
end

