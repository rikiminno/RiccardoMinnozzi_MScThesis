function viol = slackConstraintUpperBound(controlVariable, upperBound)
% function that implements the slack variable approach for a specified
% upper bound constraint

slackVariable = upperBound - controlVariable;
if slackVariable > 0
    viol = controlVariable - upperBound + slackVariable;
else
    viol = controlVariable - upperBound;
end

end
