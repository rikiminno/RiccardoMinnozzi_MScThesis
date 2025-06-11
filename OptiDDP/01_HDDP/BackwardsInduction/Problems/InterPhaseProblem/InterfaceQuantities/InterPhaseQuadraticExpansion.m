classdef InterPhaseQuadraticExpansion
    % class defining the inter-phase quadratic expansion (also including
    % the initial conditions quadratic expansion) for a generic quantity
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = public)
        % access is set to public to make it easier to set and access each
        % partial quantity where needed

        % regular quadratic expansion
        xp
        xpxp
        xpwp
        xplp
        xpxm
        xpwm
        xplm
        wp
        wpwp
        wplp
        lpwp
        wpxm
        wpwm
        wplm
        lp
        lplp
        xm
        xmxm
        xmwm
        xmlm
        wm
        wmwm
        wmlm
        lm
        lmlm

        % quadratic expansion including the initial condition
        % parametrization
        t_wp
        t_wpwp
        t_wplp
        t_wpxm
        t_wpwm
        t_lpwp
        t_wplm

        % multiplier updated expansion (and reduction)
        hat_wp
        hat_wpwp
        hat_wpxm
        hat_wpwm
        hat_wplm

        % expected reduction (updated through several steps of the
        % interphase expansion)
        ER
    end

    methods
        function obj = InterPhaseQuadraticExpansion()
            % INTERPHASEQUADRATICEXPANSION constructor

        end

    end
end


