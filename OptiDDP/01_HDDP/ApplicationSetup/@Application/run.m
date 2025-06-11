function obj = run(obj)
% function that runs the full HDDP optimization on the defined
% problem
%
% authored by Riccardo Minnozzi, 06/2024

try

    % splash screen
    fprintf('------------------------------------------------------------------------------------------------------- \n');
    fprintf('---------------------------------------- Optimization started ----------------------------------------- \n');
    fprintf('------------------------------------------------------------------------------------------------------- \n');

    % print headers
    headers = {'p', 'J', 'ER', 'ρ', 'Δ', 'f', 'σ', 'ε1'};
    centeredHeaders = cellfun(@(header, width) ...
        sprintf(['%' num2str(ceil((width - length(header)) / 2) + length(header)) 's%' num2str(floor((width - length(header)) / 2)) 's'], header, ''), ...
        headers, num2cell([4, 12, 12, 12, 12, 12, 12, 12]), 'UniformOutput', false);
    fprintf('%s   %s  %s  %s  %s  %s  %s %s\n', centeredHeaders{:});
    tic

    % start logging the iterate metrics to file
    startDir = pwd;
    cd(obj.rte.outputDirectory);
    id = fopen("metrics.txt", "w+");
    cd(startDir);
    obj.iterate.logInfo(id);

    % initialize iteration quantities
    p = 1;
    trialIterate = obj.iterate;
    global HOIST_fevalsCount_Jaug
    global HOIST_fevalsCount_cEq
    global HOIST_fevalsCount_L
    global HOIST_fevalsCount_ft
    HOIST_fevalsCount_Jaug = 0;
    HOIST_fevalsCount_cEq = 0;
    HOIST_fevalsCount_L = 0;
    HOIST_fevalsCount_ft = 0;

    % loop HDDP procedure until a hard stopping condition is met
    while obj.reInitialization.stoppingCondition ~= StoppingCondition.hardFail && ...
            obj.reInitialization.stoppingCondition ~= StoppingCondition.hardSuccess

        % update the iteration counter for all objects
        obj = obj.updateIterationCounter(p);
        obj.appendHistory();

        % - PROPAGATE THE STMS
        obj.phaseArray = obj.stmsPropagation.perform(obj.phaseArray);

        % reset the trust region quantities
        TR = [];
        TR.accepted = false;

        % loop until trust region is considered acceptable
        while ~TR.accepted

            % reset the trust region quantities
            TR = [];
            TR.accepted = false;

            % - REBUILD AND PERFORM THE BACKWARDS INDUCTION
            obj.backwardsInduction = feval(obj.algorithmConfig.version.backwardsInduction, ...
                obj.phaseArray, [-1; -1; p], ...
                obj.dummyPhaseManager);
            TR.phaseArray = obj.backwardsInduction.perform(obj.trqpSolver, ...
                obj.convergenceTest).phaseArray;

            % - PERFORM FORWARD PASS
            TR.phaseArray = obj.forwardPass.perform(TR.phaseArray);
            trialIterate = Iterate(TR.phaseArray, [-1; -1; p]);

            % - PERFORM TRUST REGION UPDATE
            [TR.accepted, trialIterate.rho, trialIterate.Delta] = ...
                obj.trqpSolver.updateTrustRegionRadius(obj.iterate, trialIterate);
            trialIterate = trialIterate.updateBackwardsInduction(TR.phaseArray);

            % log iteration metrics
            trialIterate.logInfo(id);

            % check the early termination criteria
            stopEarly = obj.reInitialization.checkEarlyTermination(trialIterate);
            if stopEarly, break; end
        end

        % - CHECK CONVERGENCE
        converged = obj.convergenceTest.perform(trialIterate);

        % only update the solution if the trust region is accepted
        if ~stopEarly
            % - SOLUTION UPDATE
            obj = obj.updateSolution(TR.phaseArray, trialIterate);

            % update the iteration counter
            p = p + 1;
        end

        % re-initialize the tolerances
        obj = obj.performReinit(converged);

        % splash screen for new iterate
        fprintf('\n-------------------------------------------------------------------------------------------------------');
    end

    % splash screen and final prints
    obj.logConvergenceMetrics();

    % save solution to files
    fclose(id);
    obj.saveSolution(false);

catch ME
    fprintf('\n');
    cd(obj.rte.appFolder);
    obj.rte.cleanupMatlabPath();
    diary off
    rethrow(ME);
end

end