classdef PenaltyUpdate_Psi_fCheckDeltaUpdateCutOffBelowAbove < PenaltyUpdate_Psi_fCheckDeltaUpdate
    % specialized class implementing penalty update by making use of the
    % constraint violation partials comupted from the backwadrs induction
    % (penalty update applied only if the expected constraint violation
    % reduction and the actual constraint violation reduction are matching
    % up to the defined eps_1, and cut off when the constraint violation is
    % close to the feasibility threshold, with update to the trust region
    % radius according to the accuracy of the constraint propagation model)
    %
    % authored by Riccardo Minnozzi, 09/2024

    methods
        function obj = PenaltyUpdate_Psi_fCheckDeltaUpdateCutOffBelowAbove(settings, eps_feas, ID)
            % PENALTYUPDATEPSIfCheckUnrestrictedCutOffBelow constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = eps_feas;
                super_args{3} = ID;
            end
            obj@PenaltyUpdate_Psi_fCheckDeltaUpdate(super_args{:});

        end

        function sigma = perform(obj, refIterate, trialIterate, phaseArray)
            % method to update the penalty parameter

            % store the reference penalty parameter
            oldSigma = refIterate.sigma;

            % check whether the feasibility threshold has been met
            if trialIterate.f < obj.settings.eps_feas
                sigma = perform@PenaltyUpdate_Psi_fCheckDeltaUpdate(obj, refIterate, trialIterate, phaseArray);
            else
                sigma = oldSigma;
            end
        end

    end
end