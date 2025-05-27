classdef PhaseConfig
    % class for the definition of initial guesses for a specified
    % optimization phase
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (SetAccess = protected, GetAccess = public)

        % initial guesses
        t
        u
        w
        l

        % sizes for column vectors
        nu
        nw
        nl
        nx

        % auxiliary data for initial guesses
        data
    end

    methods
        function obj = PhaseConfig(data)
            %PHASECONFIG constructor

            if nargin > 0
                obj.data = data;
            end

            obj.w = obj.setParametersInitialGuess();
            obj.nw = size(obj.w, 1);
            obj.t = obj.setTimeInitialGuess();
            [obj.u, obj.nu] = obj.setControlInitialGuess();
            obj.l = obj.setMultipliersInitialGuess();
            obj.nl = size(obj.l, 1);
        end
    end

    methods (Abstract, Access = protected)
        % methods that define the initial guesses as horizontal stacks of
        % column vector quantities, with mathcing column indices to the
        % corresponding time epoch

        t = setTimeInitialGuess(obj)

        [u, nu] = setControlInitialGuess(obj)

        w = setParametersInitialGuess(obj)

        l = setMultipliersInitialGuess(obj)

    end
end

