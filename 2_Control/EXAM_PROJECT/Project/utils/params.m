function p = params()
% PARAMS returns the general configuration parameters for the distributed maglev control project.

    % Number of follower agents
    p.N = 6;  % Total number of followers (6 agents)

    % Controller parameters
    p.c = 0.5;  % Coupling gain for distributed control

    % Lyapunov observer design parameters
    p.Q = eye(2);  % State weighting matrix
    p.R = 1;       % Input weighting (scalar), as in reference code

    % Pinning matrix: agent S1 is the only pinned leader
    p.G = zeros(p.N);
    p.G(1, 1) = 1;  % Only agent 1 is pinned to the leader

    % Simulation parameters
    p.sim_time = 10;    % Total simulation time [s]
    p.time_step = 0.1;  % Discretization step [s]

    % Network topology configuration
    p.topology_type = 'line';  % Choose topology: 'line', 'ring', 'mesh', 'full'

    % Leader reference input type
    p.scelta_riferimento = 'step';  % Choose input type: 'step', 'ramp', or 'sin'

    % Noise configuration
    p.noise_sensitivity = 0.1;  % Global noise scaling for the leader
    p.agent_noise_sensitivity_vector = [0.1 0 0.1 0 0 0.2];  % Per-agent noise levels

end
