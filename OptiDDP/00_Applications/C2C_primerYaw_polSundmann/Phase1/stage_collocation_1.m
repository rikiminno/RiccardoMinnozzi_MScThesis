function tPoint = stage_collocation_1(k, x, u, w)
% function that outputs the time collocation of stage k for the current
% phase

global auxdata

% get the number of stages
nStages = auxdata.nStages;

% get the initial and final true longitude
tau0 = auxdata.theta0bar;
tauf = auxdata.thetafbar;

% set the current stage collocation point
tPoint = tau0 + ((tauf - tau0)/(nStages - 1)) * (k - 1);
end

