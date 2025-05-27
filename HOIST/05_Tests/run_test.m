clear all
close all
clc

% set the applications to overwrite (if any)
benchmarksToOverwrite = ["TestLQ1"; "TestLQ2"; "TestLQ3"; ...
    "Test_R_2DI_L"; "Test_R_2DP_L"];

% tols - (t  x  u  w  l)
absTol = [0; 0; 0; 0; 0];
relTol = [0; 0; 0; 0; 0];

% instantiate the test class
unitTest = UnitTest("hotStart", absTol, relTol);

% run the unit test
testResult = unitTest.run("TestLQ1");

% display the results
resultsTable = table(testResult);
resultsTable

% save the results
cd('LastTestResults');
writetable(resultsTable,'myTestResults.csv','QuoteStrings',true);
cd('..');