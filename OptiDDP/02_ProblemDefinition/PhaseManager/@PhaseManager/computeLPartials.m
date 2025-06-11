function LPartials = computeLPartials(obj, t, x, u, w)
% function that evaluates the running cost partials on the
% current point

% evaluate the full augmented partial
LPartials = StagePartials();
X = [x; u; w];
L_X = feval(obj.L_X_file, t, X);
L_XX = feval(obj.L_XX_file, t, X);

% get the sizes and assign the partials
[nx, nu, nw, ~, ~, ~] = obj.getInputSizes();

LPartials.x = getSubMatrix(L_X, 1, 1, 1, nx); % L_X(1, 1: nx);
LPartials.u = getSubMatrix(L_X, 1, nx+1, 1, nu); % L_X(1, nx + 1: nx + nu);
LPartials.w = getSubMatrix(L_X, 1, nx+nu+1, 1, nw); % L_X(1, nx + nu + 1: nx + nu + nw);
LPartials.xx = getSubMatrix(L_XX, 1, 1, nx, nx); % L_XX(1: nx, 1: nx);
LPartials.xu = getSubMatrix(L_XX, 1, nx+1, nx, nu); % L_XX(1: nx, nx + 1: nx + nu);
LPartials.xw = getSubMatrix(L_XX, 1, nx+nu+1, nx, nw); % L_XX(1: nx, nx + nu + 1: nx + nu + nw);
LPartials.uu = getSubMatrix(L_XX, nx+1, nx+1, nu, nu); % L_XX(nx + 1: nx + nu, nx + 1: nx + nu);
LPartials.uw = getSubMatrix(L_XX, nx+1, nx+nu+1, nu, nw); % L_XX(nx + 1: nx + nu, nx + nu + 1: nx + nu + nw);
LPartials.ww = getSubMatrix(L_XX, nx+nu+1, nx+nu+1, nw, nw); % L_XX(nx + nu + 1: nx + nu + nw, nx + nu + 1: nx + nu + nw);
end