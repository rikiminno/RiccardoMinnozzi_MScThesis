classdef StmsPropagation < abstract_StmsPropagation
    % specialized class implementing the numerical propagation of state
    % transition tensors
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = StmsPropagation(settings)
            % STTPROPAGATION constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
            end
            obj@abstract_StmsPropagation(super_args{:});

        end

        function phaseArray = perform(obj, phaseArray)
            % method that performs the full propagation of the STM and STT
            % for the provided plant using the augmented state derivative
            % of phase i

            % validate inputs
            mustBeA(phaseArray, 'abstract_Phase');

            % set the number of workers
            if obj.settings.useParPool
                p = gcp("nocreate");
                nWorkers = p.NumWorkers;
            else
                nWorkers = 0;
            end

            % loop over all phase objects in the array
            for i = 1:length(phaseArray)

                % get the current phase variables
                plant = phaseArray(i).plant;
                nStages = plant.nStages;
                phaseManager = phaseArray(i).phaseManager;
                [nx, nu, nw, ~, ~, ~] = phaseManager.getInputSizes();
                nX = nx + nu + nw;

                % set the base variables for the parfor loop
                tVec = plant.t;
                xVec = plant.x;
                uVec = plant.u;
                w    = plant.w;
                base_odeObject = obj.settings.odeObject;
                global auxdata
                data = auxdata;

                % set the function handles to pass to the parfor loop
                varEq_func = str2func(phaseManager.varEq_file);
                tPoint_X_func = str2func(phaseManager.tPoint_X_file);
                ft_func = str2func(phaseManager.ft_file);
                ft_X_func = str2func(phaseManager.ft_X_file);
                setAuxdata_func = @obj.setAuxData;

                % loop over all stages of the phase
                STM = zeros(nX, nX, nStages - 1);
                STT = zeros(nX, nX, nX, nStages - 1);
                parfor (k = 1: nStages-1, nWorkers)

                    % set the stms integrator object
                    odeObject = base_odeObject;

                    % set the auxiliary global data
                    setAuxdata_func(data);

                    % set the full Stms variational equation
                    tIn = tVec(k);
                    tEnd = tVec(k + 1);
                    x = xVec(:, k);
                    u = uVec(:, k);
                    X = [x; u; w];
                    odeObject.ODEFcn = varEq_func;

                    % set the initial conditions
                    stm0 = reshape(eye(nX), nX^2, 1);
                    stt0 = reshape(zeros(nX, nX, nX), nX^3, 1);
                    odeObject.InitialValue = [X; stm0; stt0];
                    odeObject.InitialTime = tIn;

                    % propagate the stms
                    S = odeObject.solve(tEnd);

                    % retrieve and store the STM and STT solution
                    Xend = S.Solution(1 : nX, end);
                    stm = S.Solution(nX + 1: nX + nX^2, end);
                    stm = reshape(stm, nX, nX);
                    stt = S.Solution(nX + nX^2 + 1: end, end);
                    stt = reshape(stt, nX, nX, nX);

                    % add the extra terms to account for the variable stage
                    % collocation
                    extraStm = ft_func(tEnd, Xend) * ...
                        (tPoint_X_func(k + 1, Xend) - tPoint_X_func(k, X));
                    STM(:, :, k) = stm + extraStm;

                    % commented due to compatibility issues with r2021
                    % extraStt = tensorprod(ft_X_func(tEnd, Xend) * stm, ...
                    %     (tPoint_X_func(k + 1, Xend) - tPoint_X_func(k, X))');
                    stmDot = ft_X_func(tEnd, Xend) * stm;
                    dtSpandX = tPoint_X_func(k + 1, Xend) - tPoint_X_func(k, X);
                    extraStt = zeros(nX, nX, nX);
                    for ii = 1 : nX
                        for aa = 1 : nX
                            extraStt(ii, aa, :) = stmDot(ii, aa) * dtSpandX;
                        end
                    end
                    extraStt = extraStt + permute(extraStt, [1 3 2]);
                    STT(:, :, :, k) = stt + extraStt;
                end

                % set the state transition maps object and assign it to the
                % corresponding phase
                Phi = StateTransitionMaps(STM, STT);
                phaseArray(i) = phaseArray(i).setStateTransitionMaps(Phi);
            end
        end

    end
end

