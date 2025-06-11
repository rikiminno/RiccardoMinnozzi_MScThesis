function cEq_partials = computePathConstraintsPartials(obj, t, x, u, w)
% function that computes the values of the equality and inequality
% constraints partials for the current phase (and stage)

% evaluate the full augmented partial for the equality constraints
cEq_partials = StagePartials();
X = [x; u; w];
cEq = feval(obj.cEq_file, t, X);
cEq_X = feval(obj.cEq_X_file, t, X);
cEq_XX = feval(obj.cEq_XX_file, t, X);

% get the sizes and assign the partials
[nx, nu, nw, ~, ~, ~] = obj.getInputSizes();
mEq = obj.mEq;


% equality constraints
for j = 1:mEq
    % value
    cEq_partials(j).y = cEq(j, 1);

    % first order partials
    cEq_partials(j).x = getSubMatrix(cEq_X, j, 1, 1, nx);
    cEq_partials(j).u = getSubMatrix(cEq_X, j, nx+1, 1, nu);
    cEq_partials(j).w = getSubMatrix(cEq_X, j, nx+nu+1, 1, nw);

    % second order partials
    cEq_partials(j).xx = getSubMatrix(squeeze(cEq_XX(j, :, :)), 1, 1, nx, nx);
    cEq_partials(j).xu = getSubMatrix(squeeze(cEq_XX(j, :, :)), 1, nx+1, nx, nu);
    cEq_partials(j).ux = cEq_partials(j).xu';
    cEq_partials(j).xw = getSubMatrix(squeeze(cEq_XX(j, :, :)), 1, nx+nu+1, nx, nw);
    cEq_partials(j).wx = cEq_partials(j).xw';
    cEq_partials(j).uu = getSubMatrix(squeeze(cEq_XX(j, :, :)), nx+1, nx+1, nu, nu);
    cEq_partials(j).uw = getSubMatrix(squeeze(cEq_XX(j, :, :)), nx+1, nx+nu+1, nu, nw);
    cEq_partials(j).wu = cEq_partials(j).uw';
    cEq_partials(j).ww = getSubMatrix(squeeze(cEq_XX(j, :, :)), nx+nu+1, nx+nu+1, nw, nw);
end

end