classdef PenaltyUpdate_Psi < PenaltyUpdate_Psi_Basic
    % specialized class implementing  the restricted penalty update by
    % making use of the constraint violation partials comupted from the
    % backwadrs induction
    %
    % authored by Riccardo Minnozzi, 09/2024

    methods
        function obj = PenaltyUpdate_Psi(settings, eps_feas, ID)
            % PENALTYUPDATEPSI constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = eps_feas;
                super_args{3} = ID;
            end
            obj@PenaltyUpdate_Psi_Basic(super_args{:});

        end

        function sigma = perform(obj, refIterate, trialIterate, phaseArray)
            % method to update the penalty parameter

            % perform the basic update
            oldSigma = phaseArray(1).sigma;
            sigma = perform@PenaltyUpdate_Psi_Basic(obj, refIterate, trialIterate, phaseArray);

            % add safeguard against sigma becoming negative or too big
            if sigma <= 1 || sigma > 1e12, sigma = oldSigma; end

            % adjust the sign of the sigma update
            dSigma = sigma - oldSigma;
            if trialIterate.f > obj.settings.eps_feas && dSigma < 0
                sigma = oldSigma - dSigma;
            elseif trialIterate.f < obj.settings.eps_feas && dSigma > 0
                sigma = oldSigma - dSigma;
            end
            
        end

    end
end