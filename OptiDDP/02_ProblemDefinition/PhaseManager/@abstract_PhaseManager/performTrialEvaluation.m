function out = performTrialEvaluation(obj, fileToEvaluate, inputSizes)
% method to perform the trial evaluation of a file (specified
% as a property of the phase manager class)

% try an evaluation of the constraints function to retrieve the output size
try
    trialZeroInput = {};
    for i = 1:length(inputSizes)
        trialZeroInput{i} = zeros(inputSizes(i), 1);
    end
    % first try with an all zero input
    out = feval(obj.(fileToEvaluate), trialZeroInput{:});
catch
    try
        trialRandInput = {};
        for i = 1:length(inputSizes)
            trialRandInput{i} = zeros(inputSizes(i), 1);
        end
        % try again with random input
        out = feval(obj.(fileToEvaluate), trialRandInput{:});
    catch
        error("The trial evaluation of the " + string(fileToEvaluate) + ...
            " function for phase " + string(obj.ID(2)) + " failed." + ...
            " Check the existence of such function in the current phase definition.");
    end
end
end