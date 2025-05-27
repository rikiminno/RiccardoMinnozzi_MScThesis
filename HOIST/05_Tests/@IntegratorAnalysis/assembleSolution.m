function sol = assembleSolution(obj)
% function that looks into the initial guess folder of the current
% application and stores its full initial guess (for all phases)

startDir = pwd;
% move to initial guess folder
cd(obj.analysisResultsFolder);
cd("InitialGuess");

% get the phase initial guess folders
dirList = dir(fullfile(pwd, 'Phase*'));
counter = 1;
for i = 1:length(dirList)
    if dirList(i).isdir
        phaseOutputDir(counter) = string(dirList(i).name);
        counter = counter + 1;
    end
end

% get the number of phases
M = counter-1;
if M == 0, error("No phase folders located in the specified output directory."); end

% initialize the solution fields
full_t = [];
full_x = [];

% store the variables for all phases in a single array
for i = 1:M

    % move to the phase folder
    cd(phaseOutputDir(i));

    % read the current variables
    t = readmatrix("t.txt");
    x = readmatrix("x.txt");
    % u = readmatrix("u.txt");
    % w = readmatrix("w.txt");
    % l = readmatrix("l.txt");

    % vertically stack the variables
    full_t = [full_t; t];
    full_x = [full_x; x];
end

% assign the quantities to the solution structure
sol.t = full_t;
sol.x = full_x;

% move back to starting directory
cd(startDir);

end

