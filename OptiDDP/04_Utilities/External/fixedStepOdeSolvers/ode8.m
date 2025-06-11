function Y = ode8(odefun,tspan,y0,varargin)
%rk8fixed (v1.16) is an 8th order Runge-Kutta numerical integration routine.
% It requires 13 function evaluations per step.  This is not the most
% efficient 8th order implementation.  It was just the easiest to put
% together as a variant from ode78.m.
%
% 8th-order accurate RK methods have a local error estimate of O(h^9).
%
%
%   Example
%         tspan = 0:0.1:20;
%         y = ode8(@vdp1,tspan,[2 0]);
%         plot(tspan,y(:,1));
%     solves the system y' = vdp1(t,y) with a constant step size of 0.1,
%     and plots the first component of the solution.

if ~isnumeric(tspan)
    error('TSPAN should be a vector of integration steps.');
end

if ~isnumeric(y0)
    error('Y0 should be a vector of initial conditions.');
end

h = diff(tspan);
if any(sign(h(1))*h <= 0)
    error('Entries of TSPAN are not in order.')
end

try
    f0 = feval(odefun,tspan(1),y0,varargin{:});
catch
    msg = ['Unable to evaluate the ODEFUN at t0,y0. ',lasterr];
    error(msg);
end

y0 = y0(:);   % Make a column vector.
if ~isequal(size(y0),size(f0))
    error('Inconsistent sizes of Y0 and f(t0,y0).');
end

neq = length(y0);
N = length(tspan);
Y = zeros(neq,N);

% Method coefficients -- Butcher's tableau
%
%   C | A
%   --+---
%     | B

C = [ 2./27., 1/9, 1/6, 5/12, 0.5, 5/6, 1/6, 2/3, 1/3, 1, 0, 1 ]';

A = [ 2/27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;
    1/36, 1/12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;
    1/24, 0, 1/8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;
    5/12, 0, -25/16, 25/16, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;
    0.05, 0, 0, 0.25, 0.2, 0, 0, 0, 0, 0, 0, 0, 0 ;
    -25/108, 0, 0, 125/108, -65/27, 125/54, 0, 0, 0, 0, 0, 0, 0 ;
    31/300, 0, 0, 0, 61/225, -2/9, 13/900, 0, 0, 0, 0, 0, 0 ;
    2, 0, 0, -53/6, 704/45, -107/9, 67/90, 3, 0, 0, 0, 0, 0 ;
    -91/108, 0, 0, 23/108, -976/135, 311/54, -19/60, 17/6, -1/12, 0, 0, 0, 0 ;
    2383/4100, 0, 0, -341/164, 4496/1025, -301/82, 2133/4100, 45/82, 45/164, 18/41, 0, 0, 0 ;
    3/205, 0, 0, 0, 0, -6/41, -3/205, -3/41, 3/41, 6/41, 0, 0, 0 ;
    -1777/4100, 0, 0, -341/164, 4496/1025, -289/82, 2193/4100, 51/82, 33/164, 12/41, 0, 1, 0 ]';

B = [ 0, 0, 0, 0, 0, 34/105, 9/35, 9/35, 9/280, 9/280, 0, 41/840, 41/840]';

% More convenient storage
A = A.';
B = B(:);

nstages = length(B);
F = zeros(neq,nstages);

Y(:,1) = y0;
for i = 2:N
    ti = tspan(i-1);
    hi = h(i-1);
    yi = Y(:,i-1);

    % General explicit Runge-Kutta framework
    F(:,1) = feval(odefun,ti,yi,varargin{:});
    for stage = 2:nstages
        tstage = ti + C(stage-1)*hi;
        ystage = yi + F(:,1:stage-1)*(hi*A(1:stage-1,stage-1));
        F(:,stage) = feval(odefun,tstage,ystage,varargin{:});
    end
    Y(:,i) = yi + F*(hi*B);

end
Y = Y.';
