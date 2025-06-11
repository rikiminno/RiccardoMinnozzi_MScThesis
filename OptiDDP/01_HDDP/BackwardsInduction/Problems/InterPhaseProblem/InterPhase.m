classdef InterPhase < abstract_InterPhase
    % inter-phase problem class, containing properties and methods required
    % to fully define and solve the inter-phase problem
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = InterPhase(t, x, u, w, l, xm, wm, lm, sigmam, ID)
            % INTERPHASE constructor

            % call problem superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = t;
                super_args{2} = x;
                super_args{3} = u;
                super_args{4} = w;
                super_args{5} = l;
                super_args{6} = xm;
                super_args{7} = wm;
                super_args{8} = lm;
                super_args{9} = sigmam;
                super_args{10} = ID;
            end
            obj@abstract_InterPhase(super_args{:});

        end

        function obj = solve(obj, phaseManager, previousPhaseManager, trqpSolver, upstreamJopt)
            % function that fully defines the inter-phase problem and its
            % properties for the backward sweep

            % only perform the optimization on the first element of the
            % upstream Jopt (the cost expansion)
            upstreamJopt = upstreamJopt(1);

            % solve the interphase problem
            obj = obj.performExpansion(phaseManager, upstreamJopt, previousPhaseManager);
            obj = obj.solveMultipliersSubProblem(trqpSolver);
            obj = obj.solveParametersSubProblem(trqpSolver, phaseManager);
        end

        function obj = performExpansion(obj, phaseManager, upstreamJopt, previousPhaseManager)
            % function to perform the quadratic expansion for the current
            % inter-phase problem

            % evaluate the initial conditions partials
            Gamma = phaseManager.computeGammaPartials(obj.w);

            % evaluate the previous phase augmented lagrangian partials
            phit = previousPhaseManager.computePhitPartials(obj.xm, obj.wm, ...
                obj.x, obj.w, obj.lm, obj.sigmam);

            % assign the partials for the quadratic expansion at the
            % current point
            obj.J = obj.expand(upstreamJopt(1), Gamma, phit);
        end

        function obj = solveMultipliersSubProblem(obj, trqpSolver)
            % function to solve the multipliers update for the inter-phase
            % problem

            if obj.problemToSolve == ProblemVariant.multipliers
                % compute and apply the multipliers update law
                [obj.lUpdateLaw, obj.q]  = trqpSolver.solve(obj);
                obj.J           = obj.lUpdateLaw.updateExpansion(obj.J);

                % update the problemToSolve so that the static parameters
                % are updated next
                obj.problemToSolve = ProblemVariant.parameters;
            else
                error(strcat("An attempt has been made to solve the inter-",...
                    "phase multipliers sub-problem while the current problemToSolve is: ", ...
                    string(obj.problemToSolve)));
            end
        end

        function obj = solveParametersSubProblem(obj, trqpSolver, phaseManager)
            % function to perform the minimization of phase static
            % parameters

            if obj.problemToSolve == ProblemVariant.parameters
                % compute the parameters update law
                [obj.wUpdateLaw, obj.q]  = trqpSolver.solve(obj, phaseManager);
                obj.Jopt        = obj.wUpdateLaw.updateExpansion(obj.J);

            else
                error(strcat("An attempt has been made to solve the inter-",...
                    "phase parameters sub-problem while the current problemToSolve is: ", ...
                    string(obj.problemToSolve)));
            end
        end
    end

    methods (Access = protected)

        function J = expand(obj, upstreamStageExpansion, InitialConditionParametrization, interPhaseAdditionalPartial)
            % method that computes the general inter-phase expansion of a
            % quantity

            % initialize output
            J = InterPhaseQuadraticExpansion();

            % assign the partials for the quadratic expansion at the
            % current point
            J.xp      = upstreamStageExpansion.x + interPhaseAdditionalPartial.xp;
            J.xpxp    = upstreamStageExpansion.xx + interPhaseAdditionalPartial.xpxp;
            J.xpwp    = upstreamStageExpansion.xw + interPhaseAdditionalPartial.xpwp;
            J.xplp    = upstreamStageExpansion.xl;
            J.xpxm    = interPhaseAdditionalPartial.xpxm;
            J.xpwm    = interPhaseAdditionalPartial.xpwm;
            J.xplm    = interPhaseAdditionalPartial.xplm;
            J.wp      = upstreamStageExpansion.w + interPhaseAdditionalPartial.wp;
            J.t_wp    = J.wp + J.xp * InitialConditionParametrization.w;
            J.wpwp    = upstreamStageExpansion.ww + interPhaseAdditionalPartial.wpwp;
            J.t_wpwp  = J.wpwp + ...
                tensorMatrixMultiply(InitialConditionParametrization.ww, J.xp') + ...
                InitialConditionParametrization.w' * J.xpxp * InitialConditionParametrization.w +...
                InitialConditionParametrization.w' * J.xpwp + ...
                J.xpwp' * InitialConditionParametrization.w;
            J.wplp    = upstreamStageExpansion.wl;
            J.lpwp    = J.wplp';
            J.t_wplp   = J.wplp + InitialConditionParametrization.w' * J.xplp;
            J.t_lpwp   = J.t_wplp';
            J.wpxm    = interPhaseAdditionalPartial.wpxm;
            J.t_wpxm   = J.wpxm + InitialConditionParametrization.w' * J.xpxm;
            J.wpwm    = interPhaseAdditionalPartial.wpwm;
            J.t_wpwm   = J.wpwm + InitialConditionParametrization.w' * J.xpwm;
            J.wplm    = interPhaseAdditionalPartial.wplm;
            J.t_wplm   = J.wplm + InitialConditionParametrization.w' * J.xplm;
            J.lp      = upstreamStageExpansion.l;
            J.lplp    = upstreamStageExpansion.ll;
            J.xm      = interPhaseAdditionalPartial.xm;
            J.xmxm    = interPhaseAdditionalPartial.xmxm;
            J.xmwm    = interPhaseAdditionalPartial.xmwm;
            J.xmlm    = interPhaseAdditionalPartial.xmlm;
            J.wm      = interPhaseAdditionalPartial.wm;
            J.wmwm    = interPhaseAdditionalPartial.wmwm;
            J.wmlm    = interPhaseAdditionalPartial.wmlm;
            J.lm      = interPhaseAdditionalPartial.lm;
            J.lmlm    = interPhaseAdditionalPartial.lmlm;

            % assign the upstream expected reduction
            J.ER      = upstreamStageExpansion.ER;
        end

    end
end

