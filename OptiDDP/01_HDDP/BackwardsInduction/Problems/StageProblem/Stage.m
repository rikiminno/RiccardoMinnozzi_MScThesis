classdef Stage < abstract_Stage
    % stage base class, containing the default quantities that identify an
    % optimization stage
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = Stage(t, x, u, w, l, STM, STT, ID)
            % STAGE constructor

            % abstract interphase superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = t;
                super_args{2} = x;
                super_args{3} = u;
                super_args{4} = w;
                super_args{5} = l;
                super_args{6} = STM;
                super_args{7} = STT;
                super_args{8} = ID;
            end
            obj@abstract_Stage(super_args{:});

        end

        function obj = solve(obj, upstreamJopt, phaseManager, trqpSolver)
            % function that fully solves the stage problem, defining all
            % its required properties for the backwards sweep

            % only perform the optimization on the first element of the
            % upstream Jopt (the cost expansion)
            upstreamJopt = upstreamJopt(1);

            % solve the stage problem
            obj = obj.performExpansion(upstreamJopt, phaseManager);
            obj = obj.solveStageSubProblem(trqpSolver, phaseManager);
        end

        function obj = performExpansion(obj, upstreamJopt, phaseManager)
            % function to perform the quadratic expansion of the current
            % stage

            % evaluate partials
            L = phaseManager.computeLPartials(obj.t, obj.x, obj.u, obj.w);

            % get dimensions and state transition maps
            STM = obj.STM;
            STT = obj.STT;

            % perform the stage expansion
            obj.J = obj.expand(upstreamJopt, L, STM, STT);

        end

        function obj = solveStageSubProblem(obj, trqpSolver, phaseManager)
            % function to solve the stage quadratic sub-problem

            if obj.problemToSolve == ProblemVariant.controls
                % get the controls update law
                [obj.uUpdateLaw, obj.q]  = trqpSolver.solve(obj, phaseManager);
                obj.Jopt        = obj.uUpdateLaw.updateExpansion(obj.J);

            else
                error(strcat("An attempt has been made to solve the stage",...
                    " controls sub-problem while the current problemToSolve is: ", ...
                    string(obj.problemToSolve)));
            end
        end

    end

    methods (Access = protected)

        function J = expand(obj, upstreamStageExpansion, stageAdditionalPartial, STM, STT)
            % method that performs the stage quadratic expansion of a
            % generic quantity

            % initialize output
            J = StageQuadraticExpansion();

            % retrieve point quantities sizes
            nx = size(obj.x, 1);
            nu = size(obj.u, 1);
            nw = size(obj.w, 1);
            nl = size(obj.l, 1);

            % define first order partial wrt augmented state
            L_X         = [stageAdditionalPartial.x stageAdditionalPartial.u stageAdditionalPartial.w];
            Jopt_X   = [upstreamStageExpansion.x  zeros(1, nu) upstreamStageExpansion.w];
            J_X   = L_X + Jopt_X * STM;
            % assign the individual partials
            J.x   = getSubMatrix(J_X, 1, 1, 1, nx);
            J.u   = getSubMatrix(J_X, 1, nx+1, 1, nu);
            J.w   = getSubMatrix(J_X, 1, nx+nu+1, 1, nw);

            % define J second order partial wrt augmented state
            L_XX        = [stageAdditionalPartial.xx stageAdditionalPartial.xu stageAdditionalPartial.xw; ...
                stageAdditionalPartial.xu' stageAdditionalPartial.uu stageAdditionalPartial.uw; ...
                stageAdditionalPartial.xw' stageAdditionalPartial.uw' stageAdditionalPartial.ww];
            Jopt_XX  = [upstreamStageExpansion.xx zeros(nx, nu) upstreamStageExpansion.xw;...
                zeros(nu, nx)    zeros(nu, nu) zeros(nu, nw); ...
                upstreamStageExpansion.xw' zeros(nw, nu) upstreamStageExpansion.ww];
            J_XX  = L_XX + STM'*Jopt_XX*STM + tensorMatrixMultiply(STT, Jopt_X');
            % assign the individual partials
            J.xx  = getSubMatrix(J_XX, 1, 1, nx, nx);
            J.xu  = getSubMatrix(J_XX, 1, nx+1, nx, nu);
            J.ux  = J.xu';
            J.xw  = getSubMatrix(J_XX, 1, nx+nu+1, nx, nw);
            J.wx  = J.xw';
            J.uu  = getSubMatrix(J_XX, nx+1, nx+1, nu, nu);
            J.uw  = getSubMatrix(J_XX, nx+1, nx+nu+1, nu, nw);
            J.wu  = J.uw';
            J.ww  = getSubMatrix(J_XX, nx+nu+1, nx+nu+1, nw, nw);

            % define and assign J partials wrt multipliers
            J.l   = upstreamStageExpansion.l;
            J.ll  = upstreamStageExpansion.ll;

            % define the J cross partials wrt to multipliers
            Jopt_Xl  = [upstreamStageExpansion.xl; zeros(nu, nl); upstreamStageExpansion.wl];
            J_Xl  = STM' * Jopt_Xl;
            % assign the individual partials
            J.xl  = getSubMatrix(J_Xl, 1, 1, nx, nl);
            J.lx  = J.xl';
            J.ul  = getSubMatrix(J_Xl, nx+1, 1, nu, nl);
            J.lu  = J.ul';
            J.wl  = getSubMatrix(J_Xl, nx+nu+1, 1, nw, nl);
            J.lw  = J.wl';

            % assign the upstream expected reduction
            J.ER  = upstreamStageExpansion.ER;
        end
    end
end

