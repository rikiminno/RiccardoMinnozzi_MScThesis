classdef abstract_Phase < Identifier
    % class implementing the basic properties and methods for the
    % specialized Phase implementations
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = protected)
        settings        {mustBeA(settings, 'abstract_AlgorithmConfig')} = AlgorithmConfig()
    end

    properties (SetAccess = protected, GetAccess = public)
        % quantities defined by external algorithm steps
        plant                   {mustBeA(plant, 'Plant')} = Plant()
        Phi                     {mustBeA(Phi, 'StateTransitionMaps')} = StateTransitionMaps()

        % parameter to be accessed in different places
        phaseManager    {mustBeA(phaseManager, 'abstract_PhaseManager')} = PhaseManager()
        sigma           {mustBeReal(sigma)} = 0
        eps_1           {mustBeReal(eps_1)} = 0

        % update laws
        stageUpdates            %{mustBeA(stageUpdates, 'abstract_UpdateLaw')} = UpdateLaw()
        % the validation is commented since MATLAB has trouble converting
        % an array of default class values to different user defined values
        % unless a user-defined conversion method is implemented
        multiplierUpdate        {mustBeA(multiplierUpdate, 'abstract_UpdateLaw')} = UpdateLaw()
        parameterUpdate         {mustBeA(parameterUpdate, 'abstract_UpdateLaw')} = UpdateLaw()

        % results of the convergence test
        acceptedHessians        = true

        % temporary/auxiliary properties
        stage                   {mustBeA(stage, 'abstract_Stage')} = Stage()
        interPhase              {mustBeA(interPhase, 'abstract_InterPhase')} = InterPhase()
    end

    methods
        function obj = abstract_Phase(ID, phaseManager, settings)
            % ABSTRACTPHASE constructor

            % call to identifier constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = ID;
            end
            obj@Identifier(super_args{:});

            % assign rest of properties
            if nargin > 0
                obj.phaseManager    = phaseManager;
                obj.settings        = settings;
            end

        end

        function [obj] = setPlant(obj, plant)
            % function to only set the new plant property for the current
            % phase

            for i = 1:length(obj)
                obj(i).plant = plant;
            end
        end

        function [obj] = setStateTransitionMaps(obj, Phi)
            % function to only set the new state transition maps for the
            % current phase

            for i = 1:length(obj)
                obj(i).Phi = Phi;
            end
        end

        function [obj] = setPenaltyParameter(obj, sigma)
            % function that sets the penalty parameter for the current
            % phase

            for i = 1:length(obj)
                obj(i).sigma = sigma;
            end
        end

        function [obj] = setQuadraticTolerance(obj, eps_1)
            % function that sets the quadratic tolerance value for the
            % current phase

            for i = 1:length(obj)
                obj(i).eps_1 = eps_1;
            end
        end

        function optimizedQuantity = getOptimizedQuantity(obj)
            % function to retrieve the phase optimized cost to go after the
            % backwards sweep

            optimizedQuantity = obj.interPhase.Jopt;
        end

    end

    methods (Abstract)

        % method to perform the backward induction on the current phase
        obj = solve(obj, prev_Jopt)

    end
end

