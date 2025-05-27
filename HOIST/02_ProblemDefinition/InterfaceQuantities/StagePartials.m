classdef StagePartials
    % class defining the partials of a generic quantity with respect to the
    % stage quantities (state, controls and parameters)
    %
    % authored by Riccardo Minnozzi, 09/2024
    
    properties (Access = public)
        x
        xx
        xu
        ux
        xw
        wx
        u
        uu
        uw
        wu
        w
        ww

        y % value of the specific quantity, only used for the constraints
    end
    
    methods
        function obj = StagePartials()
            %STAGEPARTIALS constructor

        end
        
    end
end

