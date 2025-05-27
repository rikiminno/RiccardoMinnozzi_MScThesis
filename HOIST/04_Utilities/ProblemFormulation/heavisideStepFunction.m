function gamma = heavisideStepFunction(low, up)
% function that computes the gamma transition factor between the low and
% high step values
%
% authored by Riccardo Minnozzi, 11/2024

cs = 50;
ct = 1;

gamma = 1 / (1 + exp(- cs * (up - ct * low)));

end

