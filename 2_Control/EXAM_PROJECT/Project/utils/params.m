function p = params(topology_name)
% PARAMS returns the general configuration parameters for the distributed maglev control project.

    if nargin < 1
        topology_name = 'full';  % default
    end

    % Number of follower agents
    p.N = 6;  % Total number of followers (6 agents)

    % Controller parameters
    p.c = 3.4272;  % Coupling gain for distributed control

    % Lyapunov observer design parameters
    p.Q = eye(2);  % State weighting matrix
    p.R = 1;       % Input weighting (scalar), as in reference code

    % Pinning matrix: agent S1 is the only pinned leader
    p.G = zeros(p.N);
    p.G(1, 1) = 1;  % Only agent 1 is pinned to the leader

    % Simulation parameters
    p.sim_time = 15;    % Total simulation time [s]
    p.time_step = 0.1;  % Discretization step [s]

    % Network topology configuration
    %p.topology_type = 'line';  % Choose topology: 'line', 'ring', 'mesh', 'full'
    p.topology_type = topology_name;

    % Leader reference input type
    p.scelta_riferimento = 'step';  % Choose input type: 'step', 'ramp', or 'sin'

    % Noise configuration
    p.noise_sensitivity = 0;  % Global noise scaling for the leader
    p.agent_noise_sensitivity_vector = [0.5 0.5 0.5 0.5 0.5 0.5];  % Per-agent noise levels

end
