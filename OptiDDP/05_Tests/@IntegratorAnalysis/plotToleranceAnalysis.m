function plotToleranceAnalysis(obj, solArray)
% function that plots the error metrics computed from the current tolerance
% analysis

% store benchmark solution
benchMarkSol = solArray(1);

% loop over all solutions
nTols = length(obj.absTols);

% Create figures for individual plots
figureFinalAbsError = figure;
hold on;
title('Final Absolute Error vs. tolerance');
xlabel('Tol');
ylabel('Final Absolute Error');

figureFinalRelError = figure;
hold on;
title('Final Relative Error vs. tolerance');
xlabel('Tol');
ylabel('Final Relative Error');

% Create figures for combined plots
figureAllAbsError = figure;
hold on;
title('Absolute Error Metrics');
xlabel('Time');
ylabel('Absolute Error');

figureAllRelError = figure;
hold on;
title('Relative Error Metrics');
xlabel('Time');
ylabel('Relative Error');

% initialize error metrics
finalAbsErrors = zeros(nTols, 1);
finalRelErrors = zeros(nTols, 1);

% compute and plot error metrics
for i= 2:nTols

    % set the current tolerances
    absTol = obj.absTols(i);
    relTol = obj.relTols(i);

    [timeVector, absErr, relErr] = obj.compute_error_metrics(benchMarkSol, solArray(i));

    % Store the final values of the errors
    finalAbsErrors(i) = absErr(end);
    finalRelErrors(i) = relErr(end);

    % Plot absolute error for this solution
    figure(figureAllAbsError);
    semilogy(timeVector, absErr, 'DisplayName', strcat("Tols = [", string(absTol), ", ",...
        string(relTol), "]"));

    % Plot relative error for this solution
    figure(figureAllRelError);
    semilogy(timeVector, relErr, 'DisplayName', strcat("Tols = [", string(absTol), ", ",...
        string(relTol), "]"));
end

% Plot final absolute error vs. tol
figure(figureFinalAbsError);
loglog(obj.absTols, finalAbsErrors, '--o');
grid on;
obj.saveCurrentFigure("AbsErr_vs_tol");

% Plot final relative error vs. tol
figure(figureFinalRelError);
loglog(obj.absTols, finalRelErrors, '--o');
grid on;
obj.saveCurrentFigure("RelErr_vs_tol");

% Add legends to combined plots
figure(figureAllAbsError);
legend show;
grid on;
obj.saveCurrentFigure("AbsErr_vs_time");

figure(figureAllRelError);
legend show;
grid on;
obj.saveCurrentFigure("RelErr_vs_time");

hold off;

% move back to starting directory
cd(obj.startDir);


end
