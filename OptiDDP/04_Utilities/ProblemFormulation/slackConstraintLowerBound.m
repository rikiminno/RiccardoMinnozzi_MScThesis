function viol = slackConstraintLowerBound(controlVariable, lowerBound)
% function that implements the slack variable approach for a specified
% lower bound constraint

slackVariable = controlVariable - lowerBound;
if slackVariable > 0
    viol = lowerBound - controlVariable + slackVariable;
else
    viol = lowerBound - controlVariable;
end

end

