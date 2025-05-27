classdef Iterate < Identifier
    % class defining the basic quantities required to describe the current
    % iterate solution

    properties (SetAccess = protected, GetAccess = public)
        Lsum % sum of running costs
        phi % terminal cost
        phit % augmentedLagrangian cost
        Psi_squared % squared terminal constraint violation
        Psi % terminal constraint violation
        ER % expected reduction at first stage of first phase
        J % cost functional computed on full solution
        acceptedHessians % flag checking whether the Hessians guarantee convergence
        f % constraint violation metric
        h % average phase cost
        sigma % penalty parameter
        eps_1 % quadratic model tolerance
        maxPathConstraintViolation % maximum path constraints violation
    end

    properties (Access = public)
        rho % trust region validity metric
        Delta % trust region radius
    end

    methods
        function obj = Iterate(phaseArray, ID)
            % CURRENTITERATE constructor

            % call to identifier constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = ID;
            end
            obj@Identifier(super_args{:});

            if nargin > 0
                M = length(phaseArray);

                % compute the phases costs
                obj = obj.computePhasesCosts(phaseArray);

                % compute the augmented cost functional
                obj.J = sum(obj.Lsum) + sum(obj.phit);

                % compute the constraint violation metrics
                obj.f = sqrt((sum(obj.Psi_squared))/M);
                obj.h = (sum(obj.Lsum) + sum(obj.phi))/M;

                % store penalty parameter and quadratic tolerance
                obj.sigma = phaseArray(1).sigma;
                obj.eps_1 = phaseArray(1).eps_1;

                % store cost expected reduction
                obj.ER = phaseArray(1).getOptimizedQuantity();
                obj.ER = obj.ER(1).ER;

                % check whether the quadratic expansions have been accepted
                obj.acceptedHessians = true;
                for i = 1:M
                    obj.acceptedHessians = obj.acceptedHessians && ...
                        phaseArray(i).acceptedHessians;
                end
            end
        end

        % method that updates the current iterate object to include the
        % results of the backwards induction
        obj = updateBackwardsInduction(obj, phaseArray)

        % method that updates the cost value when the penalty parameter
        % changes
        obj = updatePenaltyParameter(obj, phaseArray, sigma)

        % method that updates the value of the quadratic model tolerance
        obj = updateEps1(obj, converged)

        % method that computes the cost metrics for each phase object
        obj = computePhasesCosts(obj, phaseArray)

        % method that prints the solution metrics to file and command
        % window
        logInfo(obj, outputFileId)
    end
end

