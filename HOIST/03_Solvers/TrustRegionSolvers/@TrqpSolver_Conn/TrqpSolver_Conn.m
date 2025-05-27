classdef TrqpSolver_Conn < abstract_TrqpSolver
    % class defining the TRQP solver defined in Conn (algorithm 7.3.4)
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = TrqpSolver_Conn(settings, eps_1, Delta)
            % TRQPSOLVER_CONN constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = eps_1;
                super_args{3} = Delta;
            end
            obj@abstract_TrqpSolver(super_args{:});

        end

        % solution method defined in external file
        [updateLaw, q] = solve(obj, problem, phaseManager)

        % solution of the "pure" trust region procedure
        [da, J_a, J_aa, J_aa_inv] = solveTrustRegion(obj, problem)

    end

    % auxiliary methods for the Conn trust region solver
    methods (Static, Access = protected)
        phi = secularEq(s, Delta)
        converged = checkInteriorConvergence(lambda_L, s, Delta)
        [converged, whichCase] = checkTerminationCriteria(obj, s, Delta, currentSet, lambda, H_l, u, alpha)
        m = initHrowNorm(H, diagSign)
        u = LINPACK(L)
        [delta, v] = partialFactorization(H_l)
        s = computeStep(H, g, lambda)
    end
end

%% DEBUGGING

% % DEBUGGING
% if lambda < 0
%     ans = problem.problemToSolve;
%     ans = problem.getID();
% end
% s2 = J_aa_inv * (- J_a);
% if n == 1
%     model = 0.5 * H * s^2 + g*s;
%     if model > 0
%         ans = problem.problemToSolve;
%         ans = problem.getID();
%     end
% end
% if problem.problemToSolve ~= ProblemVariant.multipliers
%     kip = problem.getID();
%     global id
%     if ~isempty(id)
%         fprintf(id, "\n %d, %d : %10.9f | % 10.9f | %10.9f || %s", kip(1), kip(3), ...
%             lambda, s, model, string(problem.problemToSolve));
%     else
%         % fprintf("\n %d, %d : %10.9f | % 10.9f | %10.9f || %s", kip(1), kip(3), ...
%         %     lambda, s, model, string(problem.problemToSolve));
%     end
% end
%
% function plotSecularEquation(H, g, Delta, lambda_L, lambda_U, lambda)
% % function that plots the full values of the secular equations
%
% eigVecs = eig(H);
% lambda1 = min(eigVecs);
%
% nPoints = 100;
% lambda_vec = linspace(0, lambda_U, nPoints);
% phi_vec = zeros(nPoints, 1);
%
% for i = 1:nPoints
%
%     s = computeStep(H, g, lambda_vec(i));
%     phi_vec(i) = secularEq(s, Delta);
% end
%
% figure;
% title("Full plot of the secular equation");
% hold on;
% plot(lambda_vec, phi_vec, '--k', 'LineWidth',1.25, 'DisplayName',"phi");
% grid on;
% xline(lambda_L, 'DisplayName',"lambda_L", "Color",'r');
% xline(lambda_U, 'DisplayName',"lambda_U", "Color", 'r');
% xline(lambda, 'DisplayName',"lambda", "Color","g");
% xline(-lambda1, 'DisplayName',"- lambda_1", "Color","b");
% xlabel("Lambda [-]");
% ylabel("Phi [-]");
% legend("show", 'Location','best');
%
% end
%
% function plotModelValues(H, g, s, Delta)
% % function that creates a small plot to check if the computed step is
% % actually the optimal one
%
% nPoints = 1000;
%
% model = @(x) x' * H * x + g' * x;
% range = linspace(-1.5, 1.5, nPoints);
% range = range .* s;
% range = range(:, vecnorm(range) <= Delta);
%
% values = zeros(nPoints, 1);
% steps = zeros(nPoints, 1);
%
% for i = 1:size(range, 2)
%     currentStep = range(:, i);
%     values(i) = model(currentStep);
%     steps(i) = norm(currentStep);
% end
%
% figure;
% title("Model values around computed step");
% hold on;
% plot(steps, values, '-ob','LineWidth',1.25);
% xlabel("||Step||");
% ylabel("Model");
% xline(Delta, '--r');
% xline(-Delta, '--r');
% xline(s, '-g');
% grid on;
% xlim([-Delta Delta]);
%
% end


%% DEPRECATED
% % compute the lambda from the computed step (only for the
% % cases hard case)
% if whichCase == "hard" && currentSet == "G"
%     ls = - (H * s + g);
%     if norm(s) ~= 0
%         lambda = ls ./ s;
%     else
%         lambda = 0;
%     end
%     if length(unique(lambda)) == 1
%         lambda = lambda(1);
%     else
%         error("The lambda computed using the inverse formula " + ...
%             "from the trust region step in the hard case results in" + ...
%             "a non-unique vector!");
%     end
% end