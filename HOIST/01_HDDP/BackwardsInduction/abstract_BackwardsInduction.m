classdef abstract_BackwardsInduction < Identifier
    % base class for the definition of the backwards induction
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = protected)
        M                   {mustBeScalarOrEmpty(M)}
        init_Jopt           {mustBeA(init_Jopt, 'OptimizedQuantity')} = OptimizedQuantity()

        % phase 0 manager object, used to solve the interphase problem
        % between phase 0 and 1
        dummyPhaseManager   {mustBeA(dummyPhaseManager, 'abstract_PhaseManager')} = PhaseManager()
    end

    properties (SetAccess = protected, GetAccess = public)
        % fully defined array of phase objects
        phaseArray          {mustBeA(phaseArray, 'abstract_Phase')} = Phase()
    end

    methods
        function obj = abstract_BackwardsInduction(phaseArray, ID, dummyPhaseManager)
            % ABSTRACTBACKWARDSINDUCTION constructor

            % call to identifier constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = ID;
            end
            obj@Identifier(super_args{:});

            if nargin > 0
                obj.phaseArray          = phaseArray;
                obj.M                   = length(phaseArray);

                obj.dummyPhaseManager = dummyPhaseManager;
            end

        end

        function obj = initialize(obj)
            % function that initializes the backwards induction process by
            % computing the partials for the final stage of the final phase
            % from its phasePartials class

            finalPhase      = obj.phaseArray(end);
            [~, x, ~, w, l] = finalPhase.plant.getFinalPoint();
            sigma = finalPhase.sigma;
            obj.init_Jopt   = finalPhase.phaseManager.computeInitializationPartials(...
                x, w, l, sigma);
        end

    end

    methods (Abstract)

        % method to perform the full backwards induction procedure
        obj = perform(obj)

    end

end

