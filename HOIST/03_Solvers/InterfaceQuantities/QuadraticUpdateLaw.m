classdef QuadraticUpdateLaw < abstract_UpdateLaw
    % class defining the quadratic update law resulting from the solution
    % of a constrained stage using the quadratic approximation of the
    % controls
    %
    % authored by Riccardo Minnozzi, 09/2024

    properties (Access = protected)
        du_0
        U_x
        U_w
        U_l
        U_xx
        U_xw
        U_wx
        U_xl
        U_lx
        U_ww
        U_wl
        U_lw
        U_ll

        nx
        nu
        nw
        nl
    end

    methods
        function obj = QuadraticUpdateLaw(du_0, U_x, U_w, U_l, U_xx, U_xw, U_xl, ...
                U_ww, U_wl, U_ll, problemSolved)
            % UPDATELAW constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = problemSolved;
            end
            obj@abstract_UpdateLaw(super_args{:});

            if nargin > 0
                if problemSolved == ProblemVariant.controls
                    % the quadratic update law is only applied to the stage
                    % problem
                    obj.du_0    = du_0;
                    obj.U_x     = U_x;
                    obj.U_w     = U_w;
                    obj.U_l     = U_l;
                    obj.U_xx    = U_xx;
                    obj.U_xw    = U_xw;
                    obj.U_wx    = permute(U_xw, [1 3 2]);
                    obj.U_xl    = U_xl;
                    obj.U_lx    = permute(U_xl, [1 3 2]);
                    obj.U_ww    = U_ww;
                    obj.U_wl    = U_wl;
                    obj.U_lw    = permute(U_wl, [1 3 2]);
                    obj.U_ll    = U_ll;

                    obj.nx      = size(obj.U_x, 2);
                    obj.nu      = size(obj.du_0, 1);
                    obj.nw      = size(obj.U_w, 2);
                    obj.nl      = size(obj.U_l, 2);
                else
                    % if the current problem is not a control problem,
                    % throw an error
                    error("The current quadratic update law does not support " + ...
                        "problems of type: " + string(problemSolved));
                end
            end
        end

        function du = getFeedForwardTerm(obj)
            % function that outputs the feedforward term of the current
            % update law object

            du = obj.du_0;
        end

        function du = computeUpdate(obj, dx, dw, dl)
            % function that computes the control update from the point
            % deviations

            % initialize control update
            du = obj.du_0 + [obj.U_x obj.U_w obj.U_l] * [dx; dw; dl];

            % loop over 2nd dimension to perform tensor matrix
            % multiplication
            for j = 1:obj.nx
                du = du + (reshape(obj.U_xx(:, j, :), obj.nu, obj.nx) * dx + ...
                    reshape(obj.U_xw(:, j, :), obj.nu, obj.nw) * dw + ...
                    reshape(obj.U_xl(:, j, :), obj.nu, obj.nl) * dl) * dx(j, 1);
            end
            for k = 1:obj.nw
                du = du + (reshape(obj.U_wx(:, k, :), obj.nu, obj.nx) * dx + ...
                    reshape(obj.U_ww(:, k, :), obj.nu, obj.nw) * dw + ...
                    reshape(obj.U_wl(:, k, :), obj.nu, obj.nl) * dl) * dw(k, 1);
            end
            for i = 1:obj.nl
                du = du + (reshape(obj.U_lx(:, i, :), obj.nu, obj.nx) * dx + ...
                    reshape(obj.U_lw(:, i, :), obj.nu, obj.nw) * dw + ...
                    reshape(obj.U_ll(:, i, :), obj.nu, obj.nl) * dl) * dl(i, 1);
            end

            % make sure that the update is finite
            if any(~isfinite(du), "all"), du = zeros(size(du)); end

        end

        function Jopt = updateControlExpansion(obj, J)
            % function that applies the quadratic update to the current
            % cost expansion to compute the optimized cost

            % initialize output
            Jopt = OptimizedQuantity();

            % retrieve the problem matrices
            du_0    = obj.du_0;
            U_x     = obj.U_x ;
            U_w     = obj.U_w ;
            U_l     = obj.U_l ;
            U_xx    = obj.U_xx;
            U_xw    = obj.U_xw;
            U_wx    = obj.U_wx;
            U_xl    = obj.U_xl;
            U_lx    = obj.U_lx;
            U_ww    = obj.U_ww;
            U_wl    = obj.U_wl;
            U_lw    = obj.U_lw;
            U_ll    = obj.U_ll;

            % perform the update
            Jopt.ER     = J.ER + J.u*du_0 + 0.5*du_0'*J.uu*du_0;

            % first order partials
            Jopt.x = J.x + J.u*U_x + du_0'*J.ux + du_0'*J.uu*U_x;
            Jopt.w = J.w + J.u*U_w + du_0'*J.uw + du_0'*J.uu*U_w;
            Jopt.l = J.l + J.u*U_l + du_0'*J.ul + du_0'*J.uu*U_l;

            % second order partials (matrix terms)
            Jopt.xx= J.xx + 2*J.xu*U_x + U_x'*J.uu*U_x;
            Jopt.ww= J.ww + 2*J.wu*U_w + U_w'*J.uu*U_w;
            Jopt.ll= J.ll + 2*J.lu*U_l + U_l'*J.uu*U_l;
            Jopt.xw= J.xw + J.xu*U_w + U_x'*J.uu*U_w;
            Jopt.xl= J.xl + J.xu*U_l + U_x'*J.uu*U_l;
            Jopt.wl= J.wl + J.wu*U_l + U_w'*J.uu*U_l;
            % (tensor terms)
            for i = 1 : obj.nu
                Jopt.xx = Jopt.xx + reshape(U_xx(i, :, :), obj.nx, obj.nx) * ...
                    (J.u(1, i) + J.uu(i, :) * du_0);
                Jopt.ww = Jopt.ww + reshape(U_ww(i, :, :), obj.nw, obj.nw) * ...
                    (J.u(1, i) + J.uu(i, :) * du_0);
                Jopt.ll = Jopt.ll + reshape(U_ll(i, :, :), obj.nl, obj.nl) * ...
                    (J.u(1, i) + J.uu(i, :) * du_0);
                Jopt.xw = Jopt.xw + reshape(U_xw(i, :, :), obj.nx, obj.nw) * ...
                    (J.u(1, i) + J.uu(i, :) * du_0);
                Jopt.xl = Jopt.xl + reshape(U_xl(i, :, :), obj.nx, obj.nl) * ...
                    (J.u(1, i) + J.uu(i, :) * du_0);
                Jopt.wl = Jopt.wl + reshape(U_wl(i, :, :), obj.nw, obj.nl) * ...
                    (J.u(1, i) + J.uu(i, :) * du_0);
            end

            % transpose terms
            Jopt.wx = Jopt.xw';
            Jopt.lx = Jopt.xl';
            Jopt.lw = Jopt.wl';

        end

        function Jopt = updateMultiplierExpansion(obj, J)
            % still not implemented
            error("The current quadratic update law does not support " + ...
                "problems of type: " + string(obj.problemSolved));

        end

        function Jopt = updateParameterExpansion(obj, J)
            % still not implemented
            error("The current quadratic update law does not support " + ...
                "problems of type: " + string(obj.problemSolved));
        end

    end
end

