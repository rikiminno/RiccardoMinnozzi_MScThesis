classdef abstract_ForwardPass < Identifier
    % base class implementing the methods and properties required to run
    % the forward pass
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = protected)
        settings {mustBeA(settings, 'abstract_AlgorithmConfig')} = AlgorithmConfig()
    end

    methods
        function obj = abstract_ForwardPass(settings, ID)
            % ABSTRACTFORWARDPASS constructor

            % call to identifier constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = ID;
            end
            obj@Identifier(super_args{:});

            if nargin > 0
                obj.settings = settings;
            end
        end

    end

    methods (Abstract)

        % method to actually perform the forward pass and update the array
        % of optimization phases
        phaseArray = perform(obj, phaseArray)

        % method to build the full initial guess plant object from the user
        % defined initial guess
        phaseArray = buildInitialGuess(obj, phaseArray)

    end
end

