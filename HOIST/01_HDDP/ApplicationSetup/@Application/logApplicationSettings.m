function logApplicationSettings(obj)
% method that prints to command window (and to log file) the settings used
% for the current HDDP run

% splash screen for settings
fprintf("/----------------------------------------/\n");
fprintf("/---------- ALGORITHM SETTINGS ----------/\n");
fprintf("/----------------------------------------/\n");
fprintf("\n");
% class versions
fprintf(" ---------------------------------------- \n");
fprintf(" -> Algorithm version: \n");
fprintf("   %-10s: %s \n", "BI", string(obj.algorithmConfig.version.backwardsInduction));
fprintf("   %-10s: %s \n", "Phase", string(obj.algorithmConfig.version.phase));
fprintf("   %-10s: %s \n", "Stage", string(obj.algorithmConfig.version.stage));
fprintf("   %-10s: %s \n", "I-phase", string(obj.algorithmConfig.version.interPhase));
fprintf("   %-10s: %s \n", "FP", string(obj.algorithmConfig.version.forwardPass));
fprintf("   %-10s: %s \n", "STM_prop", string(obj.algorithmConfig.version.stmsPropagation));
fprintf("   %-10s: %s \n", "TRQP_sol", string(obj.algorithmConfig.version.trqpSolver));
fprintf("   %-10s: %s \n", "CS_sol", string(obj.algorithmConfig.version.constrainedSystemSolver));
fprintf("   %-10s: %s \n", "CT", string(obj.algorithmConfig.version.convergenceTest));
fprintf("   %-10s: %s \n", "IU", string(obj.algorithmConfig.version.iterationUpdate));
fprintf("   %-10s: %s \n", "PU", string(obj.algorithmConfig.version.penaltyUpdate));
fprintf("   %-10s: %s \n", "PM", string(obj.algorithmConfig.version.phaseManager));

% convergence criteria
fprintf(" ---------------------------------------- \n");
fprintf(" -> Convergence criteria: \n");
fprintf("   %-10s: %s \n", "ε_{opt}", string(obj.algorithmConfig.eps_opt));
fprintf("   %-10s: %s \n", "ε_{feas}", string(obj.algorithmConfig.eps_feas));

% trust region solvers
fprintf(" ---------------------------------------- \n");
fprintf(" -> Trust region algorithm settings: \n");
fprintf("   %-10s: %s \n", "Δ_0", string(obj.algorithmConfig.Delta_0));
fprintf("   %-10s: %s \n", "k_d", string(obj.algorithmConfig.kd));
fprintf("   %-10s: %s \n", "ε_1", string(obj.algorithmConfig.eps_1));
fprintf("   %-10s: %s \n", "HesShift", string(obj.algorithmConfig.HesShift));
fprintf(" -> Conn TRQP solver settings: \n");
fprintf("   %-10s: %s \n", "k_{easy}", string(obj.algorithmConfig.kEasy));
fprintf("   %-10s: %s \n", "k_{hard}", string(obj.algorithmConfig.kHard));
fprintf("   %-10s: %s \n", "θ", string(obj.algorithmConfig.theta));

% penalty parameter
fprintf(" ---------------------------------------- \n");
fprintf(" -> Penalty parameter settings: \n");
fprintf("   %-10s: %s \n", "σ_0", string(obj.algorithmConfig.sigma_0));
fprintf("   %-10s: %s \n", "ks", string(obj.algorithmConfig.ks));
fprintf("   %-10s: %s \n", "Δ_{s0}", string(obj.algorithmConfig.Delta_s));
fprintf("   %-10s: %s \n", "maxIter", string(obj.algorithmConfig.maxIter));

% integrator settings
fprintf(" ---------------------------------------- \n");
fprintf(" -> Integrator settings: \n");
if isprop(obj.algorithmConfig.odeObject, "AbsoluteTolerance")
    fprintf("   %-10s: %s \n", "Solver", string(obj.algorithmConfig.odeObject.Solver));
    fprintf("   %-10s: %s \n", "AbsTol", string(obj.algorithmConfig.odeObject.AbsoluteTolerance));
    fprintf("   %-10s: %s \n", "RelTol", string(obj.algorithmConfig.odeObject.RelativeTolerance));
elseif isprop(obj.algorithmConfig.odeObject, "StepSize")
    fprintf("   %-10s: %s \n", "Solver", string(obj.algorithmConfig.odeObject.solver));
    fprintf("   %-10s: %s \n", "StepSize", string(obj.algorithmConfig.odeObject.StepSize));
end
fprintf("\n");

% final splash
fprintf("/----------------------------------------/\n");
fprintf("/---------- ////////////////// ----------/\n");
fprintf("/----------------------------------------/\n");
fprintf("\n");
fprintf("\n");
fprintf("\n");

end