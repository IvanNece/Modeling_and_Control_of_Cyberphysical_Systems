
addpath("control/")
addpath("topologies/")
addpath("utils/")

references = {'step', 'ramp', 'sin'};
colors = lines(length(references));
sim_model = 'Local.slx';

% Fixed parameters
topology_name = 'line';
c_value = 0.5;

% Output storage
global_errors = {};
pos_errors = {};
vel_errors = {};
time_vectors = {};

for i = 1:length(references)
    ref = references{i};
    fprintf("\n--- Simulating reference: %s ---\n", ref);

    % Load params
    p = params(topology_name);
    p.scelta_riferimento = ref;
    p.c = c_value;

    % Generate topology
    topos = generate_topology();
    topology_data = topos.line;
    L = topology_data{1};
    G = topology_data{2};
    adj = topology_data{3};

    % Dynamics
    A = [0, 1; 880.87, 0];
    B = [0; -9.9453];
    C = [708.27 0];

    % Define K0 based on reference
    switch lower(ref)
        case 'step'
            eigs = [0, -1];
            K0 = place(A, B, eigs);
        case 'ramp'
            eigs = [0, 0];
            K0 = acker(A, B, eigs);
        case 'sin'
            eigs = [+1j, -1j];
            K0 = place(A, B, eigs);
        otherwise
            error('Invalid reference type.');
    end

    % Assign in workspace
    assignin('base', 'L', L);
    assignin('base', 'G', G);
    assignin('base', 'adj', adj);

    [K, c, F, L1, A0_obv, B0_obv, C0_obv, D0_obv, Aa_obv, Ba_obv, Ca_obv, Da_obv] = ...
        control(A, B, C, K0, L, G, p);

    assignin('base', 'K', K);
    assignin('base', 'F', F);
    assignin('base', 'L1', L1);
    assignin('base', 'A0_obv', A0_obv);
    assignin('base', 'B0_obv', B0_obv);
    assignin('base', 'C0_obv', C0_obv);
    assignin('base', 'D0_obv', D0_obv);
    assignin('base', 'Aa_obv', Aa_obv);
    assignin('base', 'Ba_obv', Ba_obv);
    assignin('base', 'Ca_obv', Ca_obv);
    assignin('base', 'Da_obv', Da_obv);
    assignin('base', 'c', c);

    % Run Simulink
    simOut = sim(sim_model, ...
        'StartTime','0', ...
        'StopTime', num2str(p.sim_time), ...
        'FixedStep', num2str(p.time_step), ...
        'SaveOutput','on');

    % Extract and cut signals
    t = simOut.tout;
    ge = reshape(squeeze(simOut.Global_error), [], 1);
    pe = reshape(squeeze(simOut.Position_Error_Norm), [], 1);
    ve = reshape(squeeze(simOut.Velocity_Error_Norm), [], 1);
    Lmin = min([length(t), length(ge), length(pe), length(ve)]);

    time_vectors{i} = t(1:Lmin);
    global_errors{i} = ge(1:Lmin);
    pos_errors{i} = pe(1:Lmin);
    vel_errors{i} = ve(1:Lmin);

    fprintf("Reference %s → Lmin = %d, GE(1) = %.4g\n", ref, Lmin, ge(1));
end

% Plotting folder
output_folder = 'figures/references';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 1. Global tracking error
fig1 = figure;
hold on; grid on;
for i = 1:length(references)
    plot(time_vectors{i}, global_errors{i}, ...
        'LineWidth', 1.5, 'Color', colors(i,:), 'DisplayName', references{i});
end
xlabel('Time [s]');
ylabel('Global Tracking Error');
title('Comparison of Global Tracking Error for Different References');
legend('Location','northeast');
set(gca, 'FontSize', 12);
saveas(fig1, fullfile(output_folder, 'global_tracking_error_refs.png'));

% 2. Position tracking error
fig2 = figure;
hold on; grid on;
for i = 1:length(references)
    plot(time_vectors{i}, pos_errors{i}, ...
        'LineWidth', 1.5, 'Color', colors(i,:), 'DisplayName', references{i});
end
xlabel('Time [s]');
ylabel('Position Error ∥e_{pos}∥');
title('Comparison of Position Tracking Error for Different References');
legend('Location','northeast');
set(gca, 'FontSize', 12);
saveas(fig2, fullfile(output_folder, 'position_tracking_error_refs.png'));

% 3. Velocity tracking error
fig3 = figure;
hold on; grid on;
for i = 1:length(references)
    plot(time_vectors{i}, vel_errors{i}, ...
        'LineWidth', 1.5, 'Color', colors(i,:), 'DisplayName', references{i});
end
xlabel('Time [s]');
ylabel('Velocity Error ∥e_{vel}∥');
title('Comparison of Velocity Tracking Error for Different References');
legend('Location','northeast');
set(gca, 'FontSize', 12);
saveas(fig3, fullfile(output_folder, 'velocity_tracking_error_refs.png'));
