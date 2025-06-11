classdef ForwardPass < abstract_ForwardPass
    % class implementing the forward pass through numerical integration
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = ForwardPass(settings, ID)
            % FORWARDPASS constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = ID;
            end
            obj@abstract_ForwardPass(super_args{:});
        end

        % method to produce the initial guess from the phase config file
        phaseArray = buildInitialGuess(obj, phaseArray)

        % method that actually performs the forward pass applying the
        % update laws
        phaseArray = perform(obj, phaseArray)

    end
end

% working version with no adaptive mesh
% function phaseArray = perform(obj, phaseArray)
% % function that actually performs the numerical integration for
% % the forward pass
% 
% % input validation
% mustBeA(phaseArray, 'abstract_Phase');
% 
% % initialize the 'phase 0' dummy variables, noting
% % that for the dummy phase, state, parameters and multipliers
% % are set to be constant 0
% dx = 0;
% dw = 0;
% dl = 0;
% 
% % loop over all phases
% M = length(phaseArray);
% for i = 1 : M
% 
%     % store the current phase objects
%     currentPhase = phaseArray(i);
%     phaseManager = currentPhase.phaseManager;
%     plant = currentPhase.plant;
%     stageUpdates = currentPhase.stageUpdates;
%     multiplierUpdate = currentPhase.multiplierUpdate;
%     parameterUpdate = currentPhase.parameterUpdate;
%     [nx, nu, nw, ~, ~, ~] = phaseManager.getInputSizes();
%     nX = nx + nu + nw;
% 
%     % set the current state derivative to the ode object
%     currentOde = obj.settings.odeObject;
%     augmentedStateDerivativeFunction = phaseManager.ft_file;
%     currentOde.ODEFcn = str2func(augmentedStateDerivativeFunction);
% 
%     % get the reference plant quantities
%     tRef = plant.t;
%     xRef = plant.x;
%     uRef = plant.u;
%     wRef = plant.w;
%     lRef = plant.l;
% 
%     % - PARAMETERS UPDATE
%     dw = parameterUpdate.computeUpdate(dx, dw, dl);
%     w = wRef + dw;
% 
%     % - MULTIPLIERS UPDATE
%     dl = multiplierUpdate.computeUpdate(dx, dw, dl);
%     l = lRef + dl;
% 
%     % - CONTROL UPDATES
%     nStages = plant.nStages;
% 
%     % update the initial conditions (and related deviation)
%     % for the current phase
%     x = feval(str2func(phaseManager.Gamma_file), w);
%     dx = x - xRef(:, 1);
% 
%     % initalize the new plant solution
%     Y = zeros(nX, nStages);
%     for k = 1:nStages-1
% 
%         % update the control
%         du = stageUpdates{k}.computeUpdate(dx, dw, dl);
%         u = uRef(:, k) + du;
% 
%         % assemble the augmented state and store it for
%         % solution
%         X = [x; u; w];
%         Y(:, k) = X;
% 
%         % set the solution time span
%         tIn = tRef(k);
%         tEnd = tRef(k + 1);
%         % TODO: implement here the routine for the forward pass
%         % with variable stage size
% 
%         % solve the stage integration problem
%         currentOde.InitialValue = X;
%         currentOde.InitialTime = tIn;
%         S = currentOde.solve(tEnd);
% 
%         % update initial condition (and related deviation) for
%         % the next stage update
%         x = S.Solution(1:nx, end);
%         dx = x - xRef(:, k + 1);
%     end
%     % set the last stage solution (no integration required)
%     Y(:, k + 1) = [x; u; w];
% 
%     % TODO: implement here the routine for the forward pass on
%     % extra stages appended to the end of the trajectory
% 
%     % assign the new plant object to the current phase
%     newPlant = Plant(tRef, Y(1: nx, :), Y(nx+1: nx + nu, :), ...
%         w, l);
%     phaseArray(i) = phaseArray(i).setPlant(newPlant);
% 
% end
% end

