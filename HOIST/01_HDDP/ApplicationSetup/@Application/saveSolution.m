function saveSolution(obj, isInitialGuess)
% function that saves the final optimization solution to the application
% output folder

% only save solution if it has not been saved yet
if obj.hasSolution == 0
    % get the phase array
    phaseArray = obj.phaseArray;
    M = length(phaseArray);

    % save the current directory
    startDir = pwd;

    % move to the output directory
    cd(obj.rte.outputDirectory)

    % loop over each phase
    for i = 1:M

        % get the current phase quantities
        currentPhase = phaseArray(i);
        plant = currentPhase.plant;
        t = plant.t;
        x = plant.x;
        u = plant.u;
        w = plant.w;
        l = plant.l;

        % store the time-dependent variables as vstacked row vectors
        t = t';
        x = x';
        u = u';
        % store the multipliers and parameters as rows
        w = w';
        l = l';

        % if the phase being saved is an initial guess, create the initial
        % guess folder and move there
        if isInitialGuess
            if ~exist("InitialGuess", "dir"), mkdir("InitialGuess"); end
            cd("InitialGuess");
        end

        % save the current iterate object
        iterate = obj.iterate;
        save("iterate", "iterate");

        % create and move to the corresponding phase folder
        folderName = strcat("Phase", string(i));
        warning('off', 'MATLAB:MKDIR:DirectoryExists');
        mkdir(folderName);
        warning('on', 'MATLAB:MKDIR:DirectoryExists');
        cd(folderName);

        % save each variable to its corresponding phase file
        writematrix(t, "t", "FileType","text", "WriteMode","overwrite");
        writematrix(x, "x", "FileType","text", "WriteMode","overwrite");
        writematrix(u, "u", "FileType","text", "WriteMode","overwrite");
        writematrix(w, "w", "FileType","text", "WriteMode","overwrite");
        writematrix(l, "l", "FileType","text", "WriteMode","overwrite");

        % append each variable to the full problem solution
        cd(obj.rte.outputDirectory);
        writematrix(t, "times", "FileType","text", "WriteMode","append");
        writematrix(x, "states", "FileType","text", "WriteMode","append");
        writematrix(u, "controls", "FileType","text", "WriteMode","append");
        writematrix(w, "parameters", "FileType","text", "WriteMode","append");
        writematrix(l, "multipliers", "FileType","text", "WriteMode","append");
    end

    % move back to starting directory
    cd(startDir);

    % set hasSolution flag
    if ~isInitialGuess, obj.hasSolution = 1; end
end

end

