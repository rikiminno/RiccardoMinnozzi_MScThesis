function verifySolution(obj, appName)
% function that performs the check on the current application by comparing
% its test and benchmark results

% store starting directory
startDir = pwd;

% move to benchmark folder
cd(obj.benchmarksFolder);
cd(appName);

% store the benchmark values
benchmark.t = readmatrix("times.txt");
benchmark.x = readmatrix("states.txt");
benchmark.u = readmatrix("controls.txt");
benchmark.w = readmatrix("parameters.txt");
benchmark.l = readmatrix("multipliers.txt");

% move to test result folder
cd(obj.resultsFolder);
cd(appName);

% store the test results values
test.t = readmatrix("times.txt");
test.x = readmatrix("states.txt");
test.u = readmatrix("controls.txt");
test.w = readmatrix("parameters.txt");
test.l = readmatrix("multipliers.txt");

% move back to starting folder
cd(startDir);

% perform the checks using the desired tolerances
% List of fields to compare
fields = {'t', 'x', 'u', 'w', 'l'};

% Loop through each field and verify equality
for i = 1:numel(fields)
    fieldName = fields{i};
    obj.verifyEqual(test.(fieldName), benchmark.(fieldName), ...
        ['Field ' fieldName ' does not match.\n'], 'RelTol', obj.RelTol(i), ...
        "AbsTol", obj.AbsTol(i));
end

end

