classdef PenaltyUpdate_Psi_fCheckDeltaUpdate < PenaltyUpdate_Psi_fCheck
    % specialized class implementing penalty update by making use of the
    % constraint violation partials comupted from the backwadrs induction
    % (restricted penalty update applied only if the expected constraint
    % violation reduction and the actual constraint violation reduction are
    % matching up to the defined eps_1, with update to the deltaS value
    % according to the check results)
    %
    % authored by Riccardo Minnozzi, 09/2024

    methods
        function obj = PenaltyUpdate_Psi_fCheckDeltaUpdate(settings, eps_feas, ID)
            % PENALTYUPDATEPSIfCheckDeltaUpdate constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = eps_feas;
                super_args{3} = ID;
            end
            obj@PenaltyUpdate_Psi_fCheck(super_args{:});

        end

        function sigma = perform(obj, refIterate, trialIterate, phaseArray)
            % method to update the penalty parameter

            % store feasibility metrics and constraint violations
            oldSigma = refIterate.sigma;

            % perform the basic update with f check
            sigma = perform@PenaltyUpdate_Psi_fCheck(obj, refIterate, trialIterate, phaseArray);

            % update the trust region radius according to the check result
            if oldSigma == sigma
                obj = obj.updateDelta(false);
            else
                obj = obj.updateDelta(true);
            end
        end

    end

end
