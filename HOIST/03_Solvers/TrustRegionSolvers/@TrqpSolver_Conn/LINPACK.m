function u = LINPACK(L)
% function that applies the linpack method to find a vector u which
% minimizes the u * (H * u) from the cholesky factorization of H

% initialize v and w vectors
n = size(L, 1);
v = ones(n, 1);
w = zeros(n, 1);

% loop over all components of the v vector
for k = 1:n

    % sum all previously defined components of the cholesky factorization
    prevSum = 0;
    for i = 1:k - 1
        prevSum = prevSum + L(k, i) * w(i);
    end

    % pick the +-1 value for v, and set the w component
    sumPlus = (1 - prevSum)/L(k, k);
    sumMinus = (-1 - prevSum)/L(k, k);
    if sumPlus > sumMinus
        v(k) = 1;
        w(k) = sumPlus;
    else
        v(k) = - 1;
        w(k) = sumMinus;
    end
end

% compute (and normalize) the u vector
u = (L') \ w;
u = u./norm(u);

% check to make sure the output is finite
if ~all(isfinite(u)), u = ones(size(u)); end

end