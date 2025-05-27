classdef abstract_PenaltyUpdate < handleIdentifier
    % base class implementing the base properties and methods to perform
    % the penalty update
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = protected)
        settings {mustBeA(settings, 'abstract_AlgorithmConfig')} = AlgorithmConfig()
    end

    properties (SetAccess = protected, GetAccess = public)
        eps_feas
    end

    methods
        function obj = abstract_PenaltyUpdate(settings, eps_feas, ID)
            % ABSTRACTPENALTYUPDATE constructor

            % call to identifier constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = ID;
            end
            obj@handleIdentifier(super_args{:});

            if nargin > 0
                obj.settings = settings;
                obj.eps_feas = eps_feas;
            end
        end

    end

    methods(Abstract)

        % method to implement the computation of the penalty parameter
        % update
        sigma = perform(obj, refIterate, trialIterate, phaseArray)

    end
end

