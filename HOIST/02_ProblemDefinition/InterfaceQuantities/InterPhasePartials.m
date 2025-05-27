classdef InterPhasePartials
    % class defining the partials of any quantity with respect to the
    % interphase quantities (xp, wp, lp, xm, wm, lm)
    %
    % authored by Riccardo Minnozzi, 09/2024

    properties(Access = public)
        xp
        xpxp
        xpwp
        xpxm
        xpwm
        xplm
        wp
        wpwp
        wpxm
        wpwm
        wplm
        xm
        xmxm
        xmwm
        xmlm
        wm
        wmwm
        wmlm
        lm
        lmlm
    end

    methods
        function obj = InterPhasePartials()
            % INTERPHASEPARTIALS constructor
        end

    end
end

