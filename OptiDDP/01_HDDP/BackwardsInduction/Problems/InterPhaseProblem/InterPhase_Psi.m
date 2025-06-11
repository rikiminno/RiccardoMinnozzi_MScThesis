classdef InterPhase_Psi < InterPhase
    % inter-phase problem class, containing properties and methods required
    % to fully define and solve the inter-phase problem while also
    % including the expansion and updates for the constraint violation
    %
    % authored by Riccardo Minnozzi, 09/2024

    methods
        function obj = InterPhase_Psi(t, x, u, w, l, xm, wm, lm, sigmam, ID)
            % INTERPHASEPSI constructor

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
            obj@InterPhase(super_args{:});

        end

        function obj = performExpansion(obj, phaseManager, upstreamJopt, previousPhaseManager)
            % function to perform the quadratic expansion for the current
            % inter-phase problem

            % call to regular interphase quadratic expansion
            obj = performExpansion@InterPhase(obj, phaseManager, upstreamJopt(1), previousPhaseManager);

            % evaluate the initial conditions partials
            Gamma = phaseManager.computeGammaPartials(obj.w);

            % evaluate the (dummy) cost partials and set them to zero
            dummyInterPhasePartial = previousPhaseManager.computePhitPartials(obj.xm, obj.wm, ...
                obj.x, obj.w, obj.lm, obj.sigmam);
            dummyInterPhasePartial = resetPropertiesToZero(dummyInterPhasePartial);

            % get constraints dimensions
            nPsiP = phaseManager.nPsi;
            nPsiM = previousPhaseManager.nPsi;

            % assign the partials for the quadratic expansion of the
            % constraints for the current phase (component-wise)
            for q = 1:nPsiP
                obj.J(q + 1) = obj.expand(upstreamJopt(q + 1), Gamma, dummyInterPhasePartial);
            end

            % compute the partials for the previous phase constraints
            Psi_prev = previousPhaseManager.computePsiPartials(obj.xm, obj.wm, ...
                obj.x, obj.w, obj.lm);

            % compute the upstream stage (dummy) partials for the current
            % phase and set them to zero
            dummyStageOptPartial = upstreamJopt(1);
            dummyStageOptPartial = resetPropertiesToZero(dummyStageOptPartial);

            % assign the partials for the quadratic expansion of the
            % constraints for the previous phase (component-wise)
            PsiM(nPsiM) = InterPhaseQuadraticExpansion();
            for q = 1:nPsiM
                PsiM(q) = obj.expand(dummyStageOptPartial, Gamma, Psi_prev(q));
            end

            % concatenate the PsiM and [J PsiP] in a single array so that
            % the updateLaw can be applied in a single sweep to the full
            % quadratic expansion (cost, upstream constraints and
            % downstream constraints)
            obj.J = [obj.J PsiM];
        end

        function obj = solve(obj, phaseManager, previousPhaseManager, trqpSolver, upstreamJopt)
            % function that fully defines the inter-phase problem and its
            % properties for the backward sweep

            obj = obj.performExpansion(phaseManager, upstreamJopt, previousPhaseManager);
            obj = obj.solveMultipliersSubProblem(trqpSolver);
            obj = obj.solveParametersSubProblem(trqpSolver, phaseManager);
        end

    end
end

