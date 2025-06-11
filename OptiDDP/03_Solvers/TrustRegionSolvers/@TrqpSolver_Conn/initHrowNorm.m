function m = initHrowNorm(H, diagSign)
% funtcion that computes the maximum sum of the H elements along its rows
% according to the procedure required to initialize the lambda uncertainty
% interval

% initialize max value
m = -inf;

% loop over all rows
for i = size(H, 1)

    % initialize diagonal value
    current = H(i, i) * diagSign;

    % loop over all columns
    for j = size(H, 2)

        if i ~= j
            % sum non-diagonal element
            current = current + abs(H(i, j));
        end
    end

    % store new max value
    if current > m
        m = current;
    end
end

% alternative (more efficient) computation
% m2 = max(diagSign .* diag(H) + sum(abs(H - diag(H)), 2));

end