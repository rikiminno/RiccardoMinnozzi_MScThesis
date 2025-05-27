# RiccardoMinnozzi_MScThesis
Repository for the Aerospace Engineering MSc Thesis of Riccardo Minnozzi (TU Delft). The repository is personal, therefore collaborators also have write access to the repository (please don't).

## **OptiDDP**: Optimal control powered by Differential Dynamic Programming
The repository contains the optimal control solver developed as part of the MSc Thesis "Differential Dynamic Programming for the Optimization of Many-Revolutions Solar-Sail Transfers". The software in this repository implements the Hybrid Differential Dynamic Programming (**HDDP**) algorithm [1], augmented with automatic differentiation (enabled by the ADiGator MATLAB package [2]) and novel techniques to handle path constraints and variable-duration Optimal Control Problems (**OCP**s) developed throughout this thesis. This software is entirely developed and maintained by the owner of the repository.

## User Manual
The software implements the **HDDP** algorithm to solve multi-phase hybrid optimal control problems. The first step required to use the tool is to define the optimal control problem. A fully working optimal control problem can be found in the **'Example'** folder of the '00_Applications' directory.
- **Problem definition**

    The optimal control problem to be solved is defined in a self-contained folder (referred to as applilcation folder) within the '00_Applications' directory of the tool. This folder can have an arbitrary name. 
    
    Inside the application folder, each phase of the optimal control problem is defined by a folder named **Phase*** (where * is the number of the phase), containing the following MATLAB functions:
    - **initial_condition_\***: this function contains a single input (*w*) and outputs the phase initial state *x0*
    - **state_derivative_\***: this function takes the inputs (*t, x, u, w*) and outputs the state derivative *xdot*
    - **running_cost_\***: this function takes the inputs (*t, x, u, w*) and outputs the running cost *L*
    - **termianl_cost_\***: this function takes the inputs (*xm, wm, xp, wp*) and outputs the phase terminal cost *phi*
    - **terminal_constraint_\***: this function takes the inputs (*xm, wm, xp, wp*) and outputs the phase terminal constraint violation *Psi*

    **NOTE**: if any of these functions is not defined for a specific phase (for instance, there is no terminal cost), the corresponding function shall only output a scalar 0
    

- **Problem settings**

    Having defined the optimal control problem, the solver requires additional settings to perform the optimization. In order to define the initial guesses of a specified phase, the application folder shall contain a  **PhaseConfig_\*** MATLAB class: this class inherits from the super class **PhaseConfig** and implements the following methods (*Static, Access = protected*):
    - **setTimeInitialGuess**: this method takes no input and outputs the initial guess for the time discretization *t* as a row vector
    - **setControlInitialGuess**: this method takes no input and outputs the control initial guess *u* (as a function handle that accepts the inputs *(t, x, w)*) and its size *nu*
    - **setParametersInitialGuess**: this method takes no input and outputs the static parameters initial guess *w* as a single column vector
    - **setMultipliersInitialGuess**: this method takes no input and outputs the Lagrange multipliers initial guess *l* as a single column vector

    **NOTE**: if a specific phase is defined with no terminal constraints (hence no Lagrange multipliers are required), or if no static parameters are defined, the respecive initial guesses shall only be a scalar 0. The solver cannot handle problems where the state or controls are undefined.

    Having defined the settings for each phase, also the solver settings have to be defined. To achieve this, the application folder shall contain the class **ApplicationConfig**, which inherits from the abstract super class **AlgorithmConfig**. The constructor of the **ApplicationConfig** class shall define the values of all the properties defined in the **AlgorithmConfig** class.
    
    **NOTE**: The **AlgorithmConfig** class properties depend on the specific classes used to implement certain steps of the HDDP algorithm, therefore it is subject to further adjustments

- **Run optimization**

    Having fully defined the problem and its settings, the solution can be retrieved by running the optimization. This is achieved in a script or function, defined in the application folder, where the **Application** class is instantiated: the constructor of this object only requires a string which defines the *name* of the optimization output folder. If the *name* argument is left empty, a default *name* equal to that of the application folder, with a *$date-time$* string is assigned.

    Running the **build** method for the application object instantiates all the HDDP algorithm solvers and procedures, as well as performing the automatic differentiations (using *adigator*) required to solve the problem (if the "startFlag" is set to "coldStart"). If the "startFlag" is set to "hotStart", the application only stores the partial function files (which have to be previously generated by *adigator*). These partial function files are stored in the *'build'* folder inside each **Phase\*** problem definition folder.

    Finally, the optimization is performed through the **run** method of the application object. The log and results are saved to a directory named *name* in the MATLAB *userpath*.