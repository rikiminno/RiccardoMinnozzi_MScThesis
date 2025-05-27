function storeIterateMetrics(obj, iterate)
% function that stores the optimization metrics of an iterate object to
% file

% NOTE: this part is copy-pasted from the Iterate.logInfo method

% iteration number
p = iterate.getID();
p = p(3);

% cost
J = iterate.J;

% expected reduction
ER = iterate.ER;

% trust region radius
Delta = iterate.Delta;

% rho metric
rho = iterate.rho;

% penalty parameter
sigma = iterate.sigma;

% feasibility metric
f = iterate.f;
% TODO: consider replacing this with the squared terminal constraint
% violation

% set the format string
formatString = '%4d : %12.6e  %12.6e  %12.6e  %12.6e  %12.6e  %12.6e';

% create the iterate metrics file
startDir = pwd;
cd(obj.rte.outputDirectory);

% open the metrics file
id = fopen("metrics.txt", "a+");

% append the formatted string to file
fprintf(id, formatString, p, J, ER, rho, Delta, f, sigma);

% TODO: consider not opening/closing the file at every print for efficiency
% close the file and move back to starting directory
fclose(id);
cd(startDir);
end

