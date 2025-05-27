function runTestApplication(obj, appName, type, startFlag)
% function that runs a test application to update its test results

arguments
    obj
    appName
    type {mustBeMember(type, ["test", "benchmark"])}
    startFlag {mustBeMember(startFlag, ["coldStart", "hotStart"])}
end

% store the original user path and set a new user path for
% tests
obj.originalUp = userpath;
if strcmp(type, "benchmark")
    userpath(obj.benchmarksFolder);
elseif strcmp(type, "test")
    userpath(obj.resultsFolder);
else
    error("Provided application type not valid.");
end

% remove the previous application output
cd(userpath);
obj.removeDirFromCD(appName);

% move to application folder
cd('..');
cd(appName);

% print information to command window for benchmark generation
if strcmp(type, "benchmark")
    fprintf(strcat("<> Generating ", type, " results for application: ", ...
        appName, ".<>\n"));
end

% run application
run_main(startFlag);

% final prints for benchmarks
if strcmp(type, "benchmark")
    fprintf(strcat("<-> ", type, " results for application ", ...
        appName, " generated.<->\n"));
end

% move back to the tests directory
cd('..');

% reset the user path
userpath(obj.originalUp);

end

