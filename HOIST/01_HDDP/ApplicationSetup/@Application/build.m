function obj = build(obj, NameValueArgs)
% methods that instantiates all the objects required to perform
% an application run

% get name value input arguments
arguments
    obj
    NameValueArgs.startFlag {mustBeMember(NameValueArgs.startFlag, ["coldStart", "hotStart"])} = "coldStart"
end

try
    % assign the inputs
    startFlag = NameValueArgs.startFlag;

    % instantiate the forward pass object
    obj.forwardPass = feval(obj.algorithmConfig.version.forwardPass, ...
        obj.algorithmConfig, [-1; -1; 0]);

    % instantiate the stt propagation object
    obj.stmsPropagation = feval(obj.algorithmConfig.version.stmsPropagation, ...
        obj.algorithmConfig);

    % build the problem definition files and the related phase objects
    for i = 1:length(obj.phaseManagerArray)

        if strcmp(startFlag, 'coldStart')
            % cold start each phase, generating new wrapper and
            % partials files

            obj.phaseManagerArray(i) = obj.phaseManagerArray(i).buildProblem();
            obj.phaseManagerArray(i) = obj.phaseManagerArray(i).createAllPartials();

        elseif strcmp(startFlag, 'hotStart')
            % hot start each phase, without generating new
            % files
            obj.phaseManagerArray(i) = obj.phaseManagerArray(i).setAllPartials();

        else
            error("The provided application start flag is invalid.\n");
        end

        % instantiate the corresponding phase object
        obj.phaseArray(i) = feval(obj.algorithmConfig.version.phase, ...
            [-1; i; 0], obj.phaseManagerArray(i), obj.algorithmConfig);

        % set the initial plant using the user-provided initial guess
        t = obj.phaseConfig{i}.t;
        u = obj.phaseConfig{i}.u;
        w = obj.phaseConfig{i}.w;
        l = obj.phaseConfig{i}.l;
        obj.phaseArray(i) = obj.phaseArray(i).setPlant(Plant(t, [], u, w, l));

        % propagate the provided initial guess to fully define the plant
        obj.phaseArray(i) = obj.forwardPass.buildInitialGuess(obj.phaseArray(i));
    end

    % also build the dummy phase manager object
    if strcmp(startFlag, 'coldStart')
        % build a new dummy phase manager
        obj.dummyPhaseManager = obj.dummyPhaseManager.buildProblem();
        obj.dummyPhaseManager = obj.dummyPhaseManager.createAllPartials();
    elseif strcmp(startFlag, 'hotStart')
        % set the previously existing partial files
        obj.dummyPhaseManager = obj.dummyPhaseManager.setAllPartials();
    else
        error("The provided application start flag is invalid.\n");
    end

    % instantiate the backwards induction object
    obj.backwardsInduction = feval(obj.algorithmConfig.version.backwardsInduction, ...
        obj.phaseArray,[-1; -1; 0], obj.dummyPhaseManager);

    % instantiate the iterate object
    obj.iterate = Iterate(obj.phaseArray, [-1; -1; 0]);

    % set the penalty parameter and quadratic tolerance for all phases
    for i = 1 : length(obj.phaseManagerArray)
        % set the initial penalty parameter and quadratic tolerance values
        obj.phaseArray(i) = obj.phaseArray(i).setPenaltyParameter(...
            obj.algorithmConfig.sigma_0);
        obj.phaseArray(i) = obj.phaseArray(i).setQuadraticTolerance(...
            obj.algorithmConfig.eps_1);
    end
    obj.iterate = obj.iterate.updatePenaltyParameter(obj.phaseArray, obj.algorithmConfig.sigma_0);

    % instantiate the reInitialization class
    obj.reInitialization = feval(obj.algorithmConfig.version.reInitialization, ...
        obj.algorithmConfig);

    % perform the initialization to instantiate the solvers with the right
    % tolerances
    obj = obj.performReinit(false);

    % save the initial guess solution
    obj.saveSolution(true);

catch ME
    obj.rte.cleanupMatlabPath();
    diary off
    rethrow(ME);
end
end