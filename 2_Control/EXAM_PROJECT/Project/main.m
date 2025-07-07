close all;
clear all;
clc;

addpath("control\")
addpath("topologies\")
addpath("utils\")

%% Load project parameters
p = params();  % Load system parameters from params.m

%% Noise configuration (from params.m)
noise_ts = p.time_step;  % Discrete sample time for noise blocks

assignin('base', 'leader_noise_ts', noise_ts);
assignin('base', 'noise_sensitivity', p.noise_sensitivity);

% Export individual noise sensitivity for each agent
for i = 1:p.N
    assignin('base', sprintf('agent_noise_sensitivity_%d', i), p.agent_noise_sensitivity_vector(i));
end

%% Assign agent IDs to workspace
num_agents = 6;  % Number of agents in the network

for i = 0:num_agents
    assignin('base', sprintf('agent_%d', i), i);
end

%% Select network topology (defined as string in params.m)
topology = p.topology_type;  % Options: 'line', 'ring', 'mesh', 'full'

% Generate network topology from predefined script
topos = generate_topology();
switch topology
    case 'line'
        topology_data = topos.line;       % Line topology
    case 'ring'
        topology_data = topos.ring;       % Ring topology
    case 'mesh'
        topology_data = topos.mesh;       % Mesh topology
    case 'full'
        topology_data = topos.full;       % Fully connected topology
    otherwise
        error('Invalid topology. Choose from: ''line'', ''ring'', ''mesh'', ''full''.');
end

L = topology_data{1};    % Laplacian matrix
G = topology_data{2};    % Pinning matrix (Leader is S1)
adj = topology_data{3};  % Adjacency matrix

%% System dynamics (Magnetic Levitation model)
A = [0, 1; 880.87, 0];     % State matrix
B = [0; -9.9453];          % Input matrix
C = [708.27 0];            % Output matrix
D = 0;                     % Feedthrough matrix (usually zero)

%% Control gain design and leader reference configuration
scelta = p.scelta_riferimento;  % Leader reference type: 'step', 'ramp', 'sin'

switch lower(scelta)
    case 'step'
        eigs = [0, -1]; 
        K0 = place(A, B, eigs);  % Gain K0 for step reference
    case 'ramp'
        eigs = [0, 0];
        K0 = acker(A, B, eigs);  % Gain K0 for ramp reference
    case 'sin'
        eigs = [+j, -j];
        K0 = place(A, B, eigs);  % Gain K0 for sinusoidal reference
    otherwise
        error('Invalid reference. Choose from: step, ramp, sin.');
end

% Leader system matrices 
A0 = A;
B0 = B;
C0 = [C; eye(2)];
D0 = zeros(3, 1);

%% Compute control and observer gains
[K, c, F, L1, A0_obv, B0_obv, C0_obv, D0_obv, Aa_obv, Ba_obv, Ca_obv, Da_obv] = control(A, B, C, K0, L, G, p);


