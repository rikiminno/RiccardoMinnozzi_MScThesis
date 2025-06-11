classdef StageQuadraticExpansion
    % class defining the stage quadratic expansion of a generic quantity
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = public)
        % the access is set to public so that assigning the partial values
        % through external methods is easier

        % partials with respect to stage quantities
        x
        xx
        u
        uu
        w
        ww
        l
        ll
        xu
        ux
        xw
        wx
        xl
        lx
        uw
        wu
        ul
        lu
        wl
        lw

        % expected reduction (assumes the value of the upstream ER)
        ER
    end

    methods
        function obj = StageQuadraticExpansion()
            % STAGEQUADRATICEXPANSION constructor

        end

    end
end

