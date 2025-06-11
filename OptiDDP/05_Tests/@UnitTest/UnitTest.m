classdef UnitTest < matlab.unittest.TestCase
    % Unit test class which runs a certain number of test applications and
    % compares their results against a benchmark
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties
        % folder structure
        benchmarksFolder
        resultsFolder
        originalUp

        % flags
        startFlag

        % tolerances
        AbsTol
        RelTol
    end

    methods

        function obj = UnitTest(startFlag, AbsTol, RelTol, overwrite)
            % UNITTEST constructor
            % NOTE: This constructor assumes that this unit test class is
            % always instantiated in the 05_Tests folder

            arguments
                startFlag {mustBeMember(startFlag, ["coldStart", "hotStart"])} = "hotStart"
                AbsTol (5, 1) double = [0; 0; 0; 0; 0]
                RelTol (5, 1) double = [0; 0; 0; 0; 0]
                overwrite {UnitTest.mustBeValidStrings(overwrite)} = ["undefined"]
            end

            % assign inputs
            benchmarksToOverwrite = overwrite;
            obj.AbsTol = AbsTol;
            obj.RelTol = RelTol;
            obj.startFlag = startFlag;

            % set the folder containing the benchmarks and current test
            % results
            obj.benchmarksFolder = fullfile(pwd, "BenchmarkResults");
            obj.resultsFolder = fullfile(pwd, "LastTestResults");

            % store the original user path
            obj.originalUp = userpath;

            % re-generate the benchmarks for the specified overwrites (if
            % any)
            if ~ismember("undefined", benchmarksToOverwrite)

                % loop over all benchmarks
                n = length(benchmarksToOverwrite);
                for i = 1:n

                    % get the current benchmark
                    currentBenchmark = benchmarksToOverwrite(i);

                    % run the benchmark application
                    obj.runTestApplication(currentBenchmark, "benchmark", ...
                        obj.startFlag);

                    clear global
                    delete(gcp("nocreate"));
                end
            end

        end

        function delete(obj)
            % UNITTEST destructor class

            % reset the original user path
            userpath(obj.originalUp);

        end

        % method that removes dirName from the current directory
        removeDirFromCD(obj, dirName)

        % method that runs one test application
        runTestApplication(obj, appName, startFlag)

        % method that performs the comparison
        verifySolution(obj, appName)
    end

    methods(Static)

        function mustBeValidStrings(benchmarksToOverwrite)
            % validation function for the benchmarks to overwrite

            % Define the set of valid benchmarks
            validStrings = ["undefined", "TestLQ1", "TestLQ2", "TestLQ3", ...
                "Test_R_2DI_L", "Test_R_2DP_L"];

            % Check if each string in the property value is in the valid set
            for i = 1:length(benchmarksToOverwrite)
                if ~ismember(benchmarksToOverwrite(i), validStrings)
                    error('String "%s" is not a valid value. Valid values are: %s', ...
                        benchmarksToOverwrite{i}, strjoin(validStrings, ', '));
                end
            end
        end

    end

    methods(Test)
        % Test methods

        function TestLQ1(testCase)
            % function that generates and verifies the results for the
            % application TestLQ1
            appName = "TestLQ1";

            testCase.runTestApplication(appName, "test", testCase.startFlag);
            testCase.verifySolution(appName);
        end

        function TestLQ2(testCase)
            % function that generates and verifies the results for the
            % application TestLQ2
            appName = "TestLQ2";

            testCase.runTestApplication(appName, "test", testCase.startFlag);
            testCase.verifySolution(appName);
        end

        function TestLQ3(testCase)
            % function that generates and verifies the results for the
            % application TestLQ3
            appName = "TestLQ3";

            testCase.runTestApplication(appName, "test", testCase.startFlag);
            testCase.verifySolution(appName);
        end

        function Test_R_2DI_L(testCase)
            % function that generates and verifies the results for the
            % application Test_R_2DI_L
            appName = "Test_R_2DI_L";

            testCase.runTestApplication(appName, "test", testCase.startFlag);
            testCase.verifySolution(appName);
        end

        function Test_R_2DP_L(testCase)
            % function that generates and verifies the results for the
            % application Test_R_2DP_L
            appName = "Test_R_2DP_L";

            testCase.runTestApplication(appName, "test", testCase.startFlag);
            testCase.verifySolution(appName);
        end

    end

end