classdef PenaltyUpdate_Psi_fCheck < PenaltyUpdate_Psi
    % specialized class implementing penalty update by making use of the
    % constraint violation partials comupted from the backwadrs induction
    % (restricted penalty update applied only if the expected constraint
    % violation reduction and the actual constraint violation reduction are
    % matching up to the defined eps_1)
    %
    % authored by Riccardo Minnozzi, 09/2024

    methods
        function obj = PenaltyUpdate_Psi_fCheck(settings, eps_feas, ID)
            % PENALTYUPDATEPSIfCheck constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = eps_feas;
                super_args{3} = ID;
            end
            obj@PenaltyUpdate_Psi(super_args{:});

        end

        function sigma = perform(obj, refIterate, trialIterate, phaseArray)
            % method to update the penalty parameter

            % store old penalty parameter value
            oldSigma = refIterate.sigma;

            % check the validity of the constraint violation reduction
            if obj.performFeasibilityCheck(refIterate, trialIterate, phaseArray)
                % perform the restricted penalty parameter update
                sigma = perform@PenaltyUpdate_Psi(obj, refIterate, trialIterate, phaseArray);

            else
                % don't perform the penalty parameter update
                sigma = oldSigma;
            end

        end

    end
end