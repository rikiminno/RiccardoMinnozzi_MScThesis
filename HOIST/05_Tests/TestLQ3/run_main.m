function run_main(startFlag)

% define the application
app = Application();

if strcmp(startFlag, "coldStart")
    % cleanup adigator generated files
    app.rte.removeWrapperFolder();

    % build the application files
    app = app.build("startFlag","coldStart");
else

    % use previously built application files
    app = app.build("startFlag","hotStart");
end

% run the optimization
app = app.run();