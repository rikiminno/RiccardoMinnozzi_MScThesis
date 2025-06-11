classdef OptimizedQuantity
    % class defining the updated partials of a generic quantity
    %
    % authored by Riccardo Minnozzi, 09/2024

    properties (Access = public)
        x
        xx
        xw
        wx
        xl
        lx
        w
        ww
        wl
        lw
        l
        ll

        ER
    end

    methods
        function obj = OptimizedQuantity()
            % OPTIMIZEDQUANTITY constructor

        end

    end
end

