function appendHistory(obj)
% method that saves the current control, state and parameters profile at
% each successfull iteration (also creating the required folder if needed)

% only do if flag is set to true
if obj.saveFullHistory

    % move to the application output directory
    startDir = pwd;
    cd(obj.rte.outputDirectory);

    % create the history folder if needed
    if ~isfolder("History"), mkdir("History"); end
    cd("History");

    % create the various phase folders if needed
    M = length(obj.phaseArray);
    for i = 1 : M
        currentPhase = strcat("Phase", string(i));
        if ~isfolder(currentPhase), mkdir(currentPhase); end
    end

    % loop over all phases and save the corresponding quantities
    for i = 1 : M
        % store the phase quantities
        plant = obj.phaseArray(i).plant;
        t = plant.t;
        nStages = length(t);
        t = reshape(t, 1, nStages);
        x = reshape(plant.x, [], nStages);
        u = reshape(plant.u, [], nStages);
        w = reshape(plant.w, 1, []);

        % move to the corresponding phase folder
        cd(strcat("Phase", string(i)));

        % append the phase quantities to file
        writematrix(t, "t", "FileType","text", "WriteMode","append");
        writematrix(x, "x", "FileType","text", "WriteMode","append");
        writematrix(u, "u", "FileType","text", "WriteMode","append");
        writematrix(w, "w", "FileType","text", "WriteMode","append");

        % move back to the history directory
        cd("..");
    end

    % move back to starting directory
    cd(startDir);
end
end

