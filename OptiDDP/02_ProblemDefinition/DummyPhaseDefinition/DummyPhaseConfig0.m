classdef DummyPhaseConfig0 < PhaseConfig
    % phase configuration class for the dummy phase manager object
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = DummyPhaseConfig0()
            % PHASECONFIG0 constructor

            obj@PhaseConfig();
        end
    end

    methods (Access = protected)

        function nx = setStateSize(obj)
            nx = 1;
        end

        function t = setTimeInitialGuess(obj)
            t = 0;
        end

        function [u, nu] = setControlInitialGuess(obj)
            u = 0;
            nu = 1;
        end

        function [w, nw] = setParametersInitialGuess(obj)
            w = 0;
            nw = 1;
        end

        function [l, nl] = setMultipliersInitialGuess(obj)
            l = 0;
            nl = 1;
        end

    end
end

