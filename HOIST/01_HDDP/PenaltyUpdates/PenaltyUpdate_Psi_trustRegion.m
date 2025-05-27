classdef PenaltyUpdate_Psi_trustRegion < PenaltyUpdate_Psi_Basic
    % specialized class implementing penalty update (using the constraint
    % violation partials computed during the backwards induction) as part
    % of the nested trust region application routine
    %
    % authored by Riccardo Minnozzi, 09/2024

    methods
        function obj = PenaltyUpdate_Psi_trustRegion(settings, eps_feas, ID)
            % PENALTYUPDATEPSI_Psi_trustRegion constructor

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

        function [sigma, f_ER] = perform(obj, refIterate, trialIterate, phaseArray)
            % method to update the penalty parameter

            % perform the unrestricted update
            [sigma, f_ER] = perform@PenaltyUpdate_Psi_Basic(obj, refIterate, trialIterate, phaseArray);

        end

    end
end