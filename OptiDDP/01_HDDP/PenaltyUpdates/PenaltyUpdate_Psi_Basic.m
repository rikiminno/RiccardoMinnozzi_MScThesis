classdef PenaltyUpdate_Psi_Basic < abstract_PenaltyUpdate
    % specialized class implementing penalty update by making use of the
    % constraint violation partials comupted from the backwadrs induction,
    % and applying the restricted penalty update
    %
    % authored by Riccardo Minnozzi, 09/2024

    properties (Access = protected)
        Delta_s
    end

    methods
        function obj = PenaltyUpdate_Psi_Basic(settings, eps_feas, ID)
            % PENALTYUPDATEPSIBASIC constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = eps_feas;
                super_args{3} = ID;
            end
            obj@abstract_PenaltyUpdate(super_args{:});

            obj.Delta_s = obj.settings.Delta_s;
        end

        function [sigma, f_ER] = perform(obj, refIterate, trialIterate, phaseArray)
            % method to update the penalty parameter

            % reference quantities
            f_ref = refIterate.f;
            Psi_ref = refIterate.Psi;
            oldSigma = refIterate.sigma;

            % faesibility threshold
            eps_feas = obj.settings.eps_feas;

            % preallocate derivative arrays
            M = length(phaseArray);
            dPsidY = cell(M, 1);
            dYdJ = cell(M, 1);
            finiteMask = cell(M, 1);
            dJdsigma = cell(M, 1);

            % compute the required derivatives for each phase
            % store the array sizes
            startIdx = 0;
            for i = 1:M
                % store the size of the current constraint
                nPsi = size(Psi_ref{i, 1}, 1);

                % compute the dfdPsi derivatives
                dfdPsi(1, startIdx + 1 : startIdx + nPsi) = Psi_ref{i, 1}'./(f_ref * M);

                % compute the dPsidY derivative
                PsiExpansion = phaseArray(i).interPhase.J(2 : nPsi + 1);
                for q = 1:nPsi
                    tmp_dPsidY(q, :) = [PsiExpansion(q).xp PsiExpansion(q).wp PsiExpansion(q).lp];
                end
                dPsidY{i, 1} = tmp_dPsidY;
                tmp_dPsidY = [];

                % compute the dYdJ derivative
                Jexpansion = phaseArray(i).interPhase.J(1);
                dYdJ{i, 1} = 1./ [Jexpansion.xp'; Jexpansion.wp'; Jexpansion.lp'];
                finiteMask{i, 1} = isfinite(dYdJ{i, 1});

                % compute the dJdsigma derivative
                dJdsigma{i, 1} = norm(Psi_ref{i, 1})^2;

                % assemble the dPsidsigma derivative
                dPsidsigma(startIdx + 1 : startIdx + nPsi, 1) = dPsidY{i, 1}(:, finiteMask{i, 1}) ...
                    * dYdJ{i, 1}(finiteMask{i, 1}, 1) * dJdsigma{i, 1};

                % update the following startIdx
                startIdx = startIdx + nPsi;
            end

            % compute the dfdsigma derivative
            dfdsigma = dfdPsi * dPsidsigma;

            % perform the penalty update
            expectedFeasReduction = (eps_feas - f_ref) * (1 + obj.settings.eps_1);
            deltaSigma = - expectedFeasReduction / dfdsigma;

            % clip the penalty parameter update and perform
            deltaSigma = max(min(deltaSigma, obj.Delta_s), - obj.Delta_s);
            sigma = oldSigma + deltaSigma;

            % compute the expected reduction in feasibility metric
            f_ER = deltaSigma * dfdsigma;
        end

        function accepted = performFeasibilityCheck(obj, refIterate, trialIterate, phaseArray)
            % method that checks whether the feasibility metric from the
            % forward propagated trialIterate matches the one from the
            % quadratic model computed in the phaseArray

            % store feasibility metrics and constraint violations
            f_ref = refIterate.f;
            Psi_ref = refIterate.Psi;
            M = length(phaseArray);

            % compute expected reduction in constraint violation metric
            f_ER = 0;
            for i = 1:M
                nPsi = phaseArray(i).phaseManager.nPsi;
                PsiOpt = phaseArray(i).getOptimizedQuantity();
                PsiOpt = PsiOpt(2 : nPsi + 1);
                Psi_ER = zeros(nPsi, 1);
                for q = 1:nPsi
                    Psi_ER(q, 1) = PsiOpt(q).ER;
                end
                f_ER = f_ER + norm(Psi_ER + Psi_ref{i, 1})^2;
            end
            f_ER = sqrt(f_ER/M) - f_ref;

            % compute the actual reduction in constraint violation metric
            f_AR = trialIterate.f - f_ref;

            % check the validity of the constraint violation reduction
            if abs(f_AR/f_ER - 1) < obj.settings.eps_1
                accepted = true;
            else
                accepted = false;
            end

        end

        function obj = updateDelta(obj, increase)
            % function that increases or decreases the value of the current
            % trust region radius by the defined kd

            if increase
                obj.Delta_s = obj.Delta_s * (1 + obj.settings.kd);
            else
                obj.Delta_s = obj.Delta_s * (1 - obj.settings.kd);
            end
        end

    end
end