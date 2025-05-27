classdef PenaltyUpdate < abstract_PenaltyUpdate
    % specialized class implementing the computation of the constraint
    % violations and performing the penalty update
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = PenaltyUpdate(settings, eps_feas, ID)
            % PENALTYUPDATE constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = eps_feas;
                super_args{3} = ID;
            end
            obj@abstract_PenaltyUpdate(super_args{:});

        end

        function sigma = perform(obj, refIterate, trialIterate, ~)
            % method to update the penalty parameter

            % use the first phase as reference (the penalty parameter
            % is equal for all phases)
            oldSigma = refIterate.sigma;

            % check if the penalty update is to be performed
            if refIterate.f < trialIterate.f && trialIterate.f > obj.eps_feas

                % set the constraint violation metrics
                h = trialIterate.h;
                f = trialIterate.f;

                % compute the updated penalty parameter
                sigma = max(min(0.5 * h / (f^2), oldSigma), obj.settings.ks * oldSigma);
                % sigma = max(min(0.5 * h / (f^2), obj.settings.ks * oldSigma), oldSigma);
            else
                sigma = oldSigma;
            end

        end

    end
end

