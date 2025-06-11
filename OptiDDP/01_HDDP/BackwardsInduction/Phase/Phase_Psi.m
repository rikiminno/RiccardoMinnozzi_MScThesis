classdef Phase_Psi < Phase
    % class implementing the specialized phase object for the definition
    % and solution of the backwards induction when also including the
    % constraint violation propagation
    %
    % authored by Riccardo Minnozzi, 09/2024

    properties(Access = protected)
        PsiExpansion {mustBeA(PsiExpansion, "InterPhasePsiExpansion")} = InterPhasePsiExpansion();
        PsiOpt {mustBeA(PsiOpt, "OptimizedConstraintViolation")} = OptimizedConstraintViolation();
        Jexpansion {mustBeA(Jexpansion, "InterPhaseQuadraticExpansion")} = InterPhaseQuadraticExpansion();
    end

    methods
        function obj = Phase_Psi(ID, phaseManager, settings)
            % PHASEPSI constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = ID;
                super_args{2} = phaseManager;
                super_args{3} = settings;
            end
            obj@Phase(super_args{:});

        end

        function obj = convertFromPhase(obj, phaseObj)
            % conversion method from regular Phase object to the Phase_Psi
            % object, to be used for the conversion between the two classes
            
            % individually get all the properties of the phase object and
            % assign them to the current obj
            for i = 1:length(phaseObj)
                obj(i) = obj(i).setID(phaseObj(i).getID());
                obj(i) = obj(i).setConstrainedSystemSolver(phaseObj(i).getConstrainedSystemSolver());
                obj(i) = obj(i).setTrqpSolver(phaseObj(i).getTrqpSolver());
                obj(i) = obj(i).setPlant(phaseObj(i).getPlant());
                obj(i) = obj(i).setStateTransitionMaps(phaseObj(i).getStateTransitionMaps());
                obj(i) = obj(i).setPenaltyParameter(phaseObj(i).sigma);
                obj(i).phaseManager = phaseObj(i).phaseManager;
            end
        end

        function PsiOpt = getOptimizedConstraintViolation(obj)
            % function that outputs the optimized constraint violation
            % object (related to the constraint violation of the previous
            % phase)

            PsiOpt = obj.PsiOpt;
        end

        function PsiExpansion = getFinalConstraintExpansion(obj)
            % function that outputs the final value of the partials and
            % reduction of the constraint violation for the current phase

            PsiExpansion = obj.PsiExpansion;
        end

        function Psi_ER = getConstraintExpectedReduction(obj)
            % function that outputs the cost expected reduction for the
            % current phase

            Psi_ER = obj.interPhase.PsiFinal.Psi_ER;
        end

        function Jexpansion = getFinalCostExpansion(obj)
            % function that outputs the final value of the cost partials
            % quadratic expansion for the current phase

            Jexpansion = obj.Jexpansion;
        end

        function obj = solve(obj, upstreamJopt, previousPhaseManager, xm, wm, lm, sigmam, upstreamPsiOpt)
            % function that performs the full backwards sweep on the
            % current phase

            % get the number of stages for this phase
            N_stages = obj.plant.getNumberOfStages();

            % perform the backwards induction on all stages
            for k = N_stages - 1 : -1 : 1

                % get the point quantities required to instantiate the
                % Stage object
                [t, x, u, w, l] = obj.plant.getPointAtIndex(k);
                [STM, STT] = obj.Phi.getStmsAtIndex(k);

                % set the upstream optimal cost to go
                if k < N_stages - 1
                    currentUpstJopt = obj.stage.Jopt;
                    currentUpstPsiOpt = obj.stage.PsiOpt;
                else
                    currentUpstJopt = upstreamJopt;
                    currentUpstPsiOpt = upstreamPsiOpt;
                end

                % set and solve the stage problem

                obj.stage = Stage_Psi( t, x, u, w, l, STM, STT, [k; obj.ID(2:3)]);
                obj.stage = obj.stage.solve(currentUpstJopt, obj.phaseManager, ...
                    obj.trqpSolver, obj.constrainedSystemSolver, currentUpstPsiOpt);

                % store the stage control update law solution
                if k < N_stages - 1
                    % for a generic stage, stack the current solution
                    % "before" the update laws of the upstream stages
                    prevUpdateLaw = obj.stage.getUpdateLaw();
                    obj.stageUpdates = obj.stageUpdates.stackControlFbLaws(prevUpdateLaw);
                else
                    obj.stageUpdates = obj.stage.getUpdateLaw();
                end

            end

            % finish the backwards induction by solving the inter-phase
            % problem and storing the solutions

            % set the interphase problem object
            [t, x, u, w, l] = obj.plant.getPointAtIndex(1);

            obj.interPhase = InterPhase_Psi(t, x, u, w, l, xm, wm, lm, sigmam, ...
                [0; obj.ID(2:3)]);
            % solve the interphase problem
            obj.interPhase = obj.interPhase.solve(obj.phaseManager, ...
                previousPhaseManager, obj.trqpSolver, ...
                obj.constrainedSystemSolver, obj.stage.Jopt, obj.stage.PsiOpt);
            % store the resulting control laws
            obj.multiplierUpdate    = obj.interPhase.getMultipliersUpdateLaw();
            obj.parameterUpdate     = obj.interPhase.getParametersUpdateLaw();
            % store the optimized constraint violation partials for the
            % previous phase
            obj.PsiOpt = obj.interPhase.PsiOpt;

            % store the quadratic expansions for the computation of the
            % penalty parameter update
            obj.PsiExpansion  = obj.interPhase.PsiP;
            obj.Jexpansion = obj.interPhase.J;

        end

    end
end

