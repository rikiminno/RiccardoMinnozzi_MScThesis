function logInfo(obj, outputFileId)
% function that prints the iterate metrics to screen
% iterate metrics are: iterate number, cost, expected reduction, rho metric,
% trust region radius, feasibility metric, penalty parameter

% GATHER REQUIRED ITERATION METRICS

% iteration number
p = obj.getID();
p = p(3);

% cost
J = obj.J;

% expected reduction
ER = obj.ER;

% trust region radius
Delta = obj.Delta;

% rho metric
rho = obj.rho;

% penalty parameter
sigma = obj.sigma;

% quadratic model tolerance
eps_1 = obj.eps_1;

% feasibility metric
f = obj.f;
% TODO: consider replacing this with the squared terminal constraint
% violation

% set the format string
formatString = '\n%4d : %12.5e  %12.5e  %12.5e  %12.5e  %12.5e  %12.5e %12.5e';
cvsFormatString = '%4d, %12.5e, %12.5e, %12.5e, %12.5e, %12.5e, %12.5e, %12.5e\n';

% print the required data to command window
fprintf(formatString, p, J, ER, rho, Delta, f, sigma, eps_1);

% print the data to the output file
fprintf(outputFileId, cvsFormatString, p, J, ER, rho, Delta, f, sigma, eps_1);
end

