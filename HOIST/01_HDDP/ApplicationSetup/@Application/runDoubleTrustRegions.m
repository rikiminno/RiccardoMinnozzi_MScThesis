function obj = runDoubleTrustRegions(obj)
% function that runs the full HDDP optimization on the defined problem by
% performing two loops: the first one for the control and the second one
% for the penalty parameter updates
%
% authored by Riccardo Minnozzi, 09/2024

try

    if ~isa(obj.phaseManagerArray, "PhaseManager_Psi") || ...
            ~isa(obj.backwardsInduction, "BackwardsInduction_Psi")
        error(strcat("The current optimization is set to perform", ...
            " the double trust region procedures of the control", ...
            " and penalty parameter updates, but the instantied application", ...
            " objects do not support the procedure: check the ", ...
            "'ApplicationConfig.version' property."));
    end

    % splash screen
    fprintf('----------------------------------------------------------------------------------------- \n');
    fprintf('--------------------------------- Optimization started ---------------------------------- \n');
    fprintf('----------------------------------------------------------------------------------------- \n');

    % print headers
    headers = {'p', 'J', 'ER', 'ρ', 'Δ', 'f', 'σ'};
    centeredHeaders = cellfun(@(header, width) ...
        sprintf(['%' num2str(ceil((width - length(header)) / 2) + length(header)) 's%' num2str(floor((width - length(header)) / 2)) 's'], header, ''), ...
        headers, num2cell([4, 12, 12, 12, 12, 12, 12]), 'UniformOutput', false);
    fprintf('%s   %s  %s  %s  %s  %s  %s\n', centeredHeaders{:});
    tic

    % start logging the iterate metrics to file
    startDir = pwd;
    cd(obj.rte.outputDirectory);
    id = fopen("metrics.txt", "w+");
    cd(startDir);
    obj.iterate.logInfo(id);

    % initialize iteration quantities
    converged = false;
    p = 1;
    trialIterate = obj.iterate;

    % loop HDDP procedure until convergence
    while ~converged

        % update the iteration counter for all objects
        obj = obj.updateIterationCounter(p);

        % - PROPAGATE THE STMS
        obj.phaseArray = obj.stmsPropagation.perform(obj.phaseArray);

        % reset the trqp acceptance flag and penalty parameter trust region
        trqpAccepted = false;
        sigmaTR = [];

        % loop until trust region is considered acceptable
        while ~trqpAccepted

            % - REBUILD AND PERFORM THE BACKWARDS INDUCTION
            obj.backwardsInduction = feval(obj.algorithmConfig.version.backwardsInduction, ...
                obj.phaseArray, [-1; -1; p], ...
                obj.dummyPhaseManager);
            obj.backwardsInduction = obj.backwardsInduction.perform();
            obj.phaseArray = obj.backwardsInduction.phaseArray;

            % update the trial iterate to check convergence through
            % hessians and expected cost reduction
            trialIterate = trialIterate.updateBackwardsInduction(obj.phaseArray);

            % - CHECK CONVERGENCE
            converged = obj.convergenceTest.perform(trialIterate);
            if converged && p ~= 1, break; end

            % - PERFORM FORWARD PASS
            updatedPhaseArray = obj.forwardPass.perform(obj.phaseArray);
            trialIterate = Iterate(updatedPhaseArray, [-1; -1; p]);
            trialIterate = trialIterate.updateBackwardsInduction(obj.phaseArray);

            % - PERFORM ITERATION UPDATE
            [trqpSolver, trqpAccepted, rho] = obj.iterationUpdate.perform(...
                obj.phaseArray, trialIterate);
            sigmaTR.phaseArray = obj.phaseArray; % use the last valid trust
            % region radius to perform the penalty parameter trust region
            obj.phaseArray = obj.phaseArray.setTrqpSolver(trqpSolver);

            % log iteration metrics
            trialIterate = trialIterate.setRho(rho);
            trialIterate.logInfo(id);
        end

        % PENALTY PARAMETER TRUST REGION ------------------------------
        % initialize the sigma trust region quantities
        sigmaTR.accepted = false;
        sigmaTR.nIters = 0;
        sigmaTR.oldSigma = obj.phaseArray(1).sigma;

        % loop penalty parameter trust region
        while ~sigmaTR.accepted && sigmaTR.nIters <= obj.algorithmConfig.maxIter && ~converged

            % update penalty parameter
            [sigma, f_ER] = obj.penaltyUpdate.perform(obj.phaseArray, sigmaTR.oldSigma);
            sigmaTR.phaseArray = sigmaTR.phaseArray.setPenaltyParameter(sigma);

            % compute an additional HDDP step to retrieve the actual
            % reduction in constraint violation
            sigmaTR.backwardsInduction = feval(obj.algorithmConfig.version.backwardsInduction, ...
                sigmaTR.phaseArray, [-1; -1; p], ...
                obj.dummyPhaseManager);
            sigmaTR.backwardsInduction = sigmaTR.backwardsInduction.perform();
            sigmaTR.updatedPhaseArray = obj.forwardPass.perform(sigmaTR.backwardsInduction.phaseArray);
            sigmaTR.iterate = Iterate(sigmaTR.updatedPhaseArray, [-1; -1; p]);
            sigmaTR.iterate = sigmaTR.iterate.updateBackwardsInduction(sigmaTR.phaseArray);
            f_AR = sigmaTR.iterate.f - trialIterate.f;
            rho = (sigmaTR.iterate.J - obj.iterate.J)/sigmaTR.iterate.ER;
            % log iteration metrics
            sigmaTR.iterate = sigmaTR.iterate.setRho(rho);
            sigmaTR.iterate.logInfo(id);

            % check for the penalty parameter trust region validity, cost
            % trust region validity and penalty parameter validity
            sigmaTR.accepted = abs(f_AR/f_ER - 1) < obj.algorithmConfig.eps_1 && ...
                abs(rho - 1) < obj.algorithmConfig.eps_1 && ...
                (sigma > 1 && sigma < 1e12) && ...
                sigmaTR.nIters <= obj.algorithmConfig.maxIter;

            % update the penalty parameter trust region radius
            obj.penaltyUpdate = obj.penaltyUpdate.updateTrustRegionRadius(sigmaTR.accepted);

            % reject the penalty parameter update if needed
            if ~sigmaTR.accepted, sigma = sigmaTR.oldSigma; end

            % increase current sigma trust region iterations counter
            sigmaTR.nIters = sigmaTR.nIters + 1;
        end

        % assign the last valid reference solution
        if sigmaTR.accepted
            % set the new trust region radius to forward pass solution
            sigmaTR.updatedPhaseArray = sigmaTR.updatedPhaseArray.setTrqpSolver(trqpSolver);
            obj.phaseArray = sigmaTR.updatedPhaseArray;
            % assign new penalty parameter
            obj.phaseArray = obj.phaseArray.setPenaltyParameter(sigma);
            % update reference iterate
            obj.iterate = sigmaTR.iterate;
        else
            % set the new trust region radius to forward pass solution
            updatedPhaseArray = updatedPhaseArray.setTrqpSolver(trqpSolver);
            obj.phaseArray = updatedPhaseArray;
            % assign new penalty parameter
            obj.phaseArray = obj.phaseArray.setPenaltyParameter(sigma);
            % update the reference iterate (with the new penalty parameter)
            trialIterate = trialIterate.updatePenaltyParameter(obj.phaseArray);
            obj.iterate = trialIterate;
        end

        % update reference iterate on all required objects
        obj.iterationUpdate = obj.iterationUpdate.setReferenceIterate(obj.iterate);
        obj.penaltyUpdate = obj.penaltyUpdate.setReferenceIterate(obj.iterate);

        % update iteration counter
        p = p + 1;

        % splash screen for new iterate
        fprintf('\n-----------------------------------------------------------------------------------------');
    end

    % splash screen and final prints
    tClock = toc;
    fprintf('\n\n\nConvergence reached in %8.1f seconds.\n', tClock);
    fprintf('----------------------------------------------------------------------------------------- \n');
    fprintf('-------------------------------- Optimization terminated -------------------------------- \n');
    fprintf('----------------------------------------------------------------------------------------- \n');

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