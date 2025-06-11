classdef UpdateLaw < abstract_UpdateLaw
    % class defining the update law resulting from the solution of the
    % (un)constrained system (coming from the TRQP defined from the current
    % problem class and its corresponding TRQP solution)
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = protected)
        A
        B
        C
        D
    end

    methods
        function obj = UpdateLaw(A, B, C, D, problemSolved)
            % UPDATELAW constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = problemSolved;
            end
            obj@abstract_UpdateLaw(super_args{:});

            if nargin > 0
                obj.A   = A;
                obj.B   = B;
                obj.C   = C;
                obj.D   = D;
            end
        end

        function A = getFeedForwardTerm(obj)
            % function that outputs the feedforward term of the current
            % update law object

            A = obj.A;
        end

        function da = computeUpdate(obj, dx, dw, dl)
            % method that computes the correct update depending on the kind
            % of problem solved by this update law

            % compute the update differently for the multipliers update
            if obj.problemSolved == ProblemVariant.multipliers
                da = obj.A + obj.C * dw;
            else
                da = obj.A + obj.B * dx + obj.C * dw + obj.D * dl;
            end

            % make sure that the update has finite value
            if any(~isfinite(da), "all"), da = zeros(size(da)); end
        end

        function Jopt = updateControlExpansion(obj, J)
            % case = control update

            % initialize output
            Jopt = OptimizedQuantity();

            % retrieve update matrices
            A = obj.A;
            B = obj.B;
            C = obj.C;
            D = obj.D;

            % perform the update
            Jopt.ER     = J.ER + J.u*A + 0.5*A'*J.uu*A;
            Jopt.x      = J.x + J.u*B + A'*J.uu*B + A'*J.ux;
            Jopt.xx     = J.xx + B'*J.uu*B + B'*J.ux + J.ux'*B;
            Jopt.xw     = J.xw + B'*J.uu*C + B'*J.uw + J.ux'*C;
            Jopt.xl     = J.xl + B'*J.uu*D + B'*J.ul + J.ux'*D;
            Jopt.w      = J.w + J.u*C + A'*J.uu*C + A'*J.uw;
            Jopt.ww     = J.ww + C'*J.uu*C + C'*J.uw + J.uw'*C;
            Jopt.wl     = J.wl + C'*J.uu*D + C'*J.ul + J.uw'*D;
            Jopt.l      = J.l + J.u*D + A'*J.uu*D + A'*J.ul;
            Jopt.ll     = J.ll + D'*J.uu*D + D'*J.ul + J.ul'*D;
        end

        function J = updateMultiplierExpansion(obj, J)
            % case = multiplier update

            % retrieve update matrices
            Alp = obj.A;
            Clp = obj.C;

            % perform the intermediate inter-phase update
            J.ER        = J.ER + J.lp*Alp + 0.5*Alp'*J.lplp*Alp;
            J.hat_wp    = J.t_wp + J.lp*Clp +  Alp'*J.lplp*Clp + Alp'*J.t_lpwp;
            J.hat_wpwp  = J.t_wpwp + Clp'*J.lplp*Clp +  Clp'*J.t_lpwp + J.t_lpwp'*Clp;
            J.hat_wpxm  = J.t_wpxm;
            J.hat_wpwm  = J.t_wpwm;
            J.hat_wplm  = J.t_wplm;
        end

        function Jopt = updateParameterExpansion(obj, J)
            % case = parameter update

            % initialize output
            Jopt = OptimizedQuantity();

            % retrieve update matrices
            Awp = obj.A;
            Bwp = obj.B;
            Cwp = obj.C;
            Dwp = obj.D;

            % perform the inter-phase update
            Jopt.ER = J.ER + J.hat_wp*Awp + 0.5*Awp'*J.hat_wpwp*Awp;
            Jopt.x  = J.xm + J.hat_wp*Bwp + Awp'*J.hat_wpwp*Bwp + Awp'*J.hat_wpxm;
            Jopt.xx = J.xmxm + Bwp'*J.hat_wpwp*Bwp + Bwp'*J.hat_wpxm + J.hat_wpxm'*Bwp;
            Jopt.xw = J.xmwm + Bwp'* J.hat_wpwp*Cwp + Bwp'*J.hat_wpwm + J.hat_wpxm'*Cwp;
            Jopt.xl = J.xmlm + Bwp'* J.hat_wpwp*Dwp + Bwp'*J.hat_wplm + J.hat_wpxm'*Dwp;
            Jopt.w  = J.wm + J.hat_wp*Cwp + Awp'*J.hat_wpwp*Cwp + Awp'*J.hat_wpwm;
            Jopt.ww = J.wmwm + Cwp'*J.hat_wpwp*Cwp + Cwp'*J.hat_wpwm + J.hat_wpwm'*Cwp;
            Jopt.wl = J.wmlm + Cwp'*J.hat_wpwp*Dwp + Cwp'*J.hat_wplm + J.hat_wpwm'*Dwp;
            Jopt.l  = J.lm + J.hat_wp*Dwp + Awp'*J.hat_wpwp*Dwp + Awp'*J.hat_wplm;
            Jopt.ll = J.lmlm + Dwp'*J.hat_wpwp*Dwp + Dwp'*J.hat_wplm + J.hat_wplm'*Dwp;
        end

    end
end

