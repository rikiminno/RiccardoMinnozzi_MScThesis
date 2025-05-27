classdef Plant
    % class for the definition of the plant object for a single phase

    properties (SetAccess = protected, GetAccess = public)
        t {mustBeReal(t)}
        x {mustBeReal(x)}
        u % u can be both real or a function handle (only for the initial
        % guess)
        w {mustBeReal(w)}
        l {mustBeReal(l)}

        nStages
    end

    methods
        function obj = Plant(t, x, u, w, l)
            % PLANT constructor

            if nargin > 0
                obj.t  = t;
                obj.x  = x;
                obj.u  = u;
                obj.w  = w;
                obj.l  = l;

                obj.nStages = length(obj.t);
            end
        end

        function [t, x, u, w, l] = getPointAtIndex(obj, index)
            % function to retrieve the quantities corresponding to a
            % certain index in the plant

            t = obj.t(index);
            x = obj.x(:, index);
            u = obj.u(:, index);
            w = obj.w;
            l = obj.l;

        end

        function [t, x, u, w, l] = getFinalPoint(obj)
            % method to retrieve the last point of a plant object

            [t, x, u, w, l] = getPointAtIndex(obj, obj.nStages);
        end

    end
end

