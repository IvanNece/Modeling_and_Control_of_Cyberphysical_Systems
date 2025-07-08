topologies = {'line', 'ring', 'mesh', 'full'};
colors = lines(length(topologies));
sim_model = 'Local.slx';

% Preallocation
global_errors = {};
pos_errors = {};
vel_errors = {};
time_vectors = {};

for i = 1:length(topologies)
    topology_name = topologies{i};
    fprintf("\n--- Running simulation for topology: %s ---\n", topology_name);

    % Parameters
    p = params(topology_name);

    % Topology
    topos = generate_topology();
    switch p.topology_type
        case 'line'
            topology_data = topos.line;
        case 'ring'
            topology_data = topos.ring;
        case 'mesh'
            topology_data = topos.mesh;
        case 'full'
            topology_data = topos.full;
        otherwise
            error('Invalid topology');
    end

    % Assign to Simulink workspace
    assignin('base', 'L', topology_data{1});
    assignin('base', 'G', topology_data{2});
    assignin('base', 'adj', topology_data{3});

    [K, c, F, L1, A0_obv, B0_obv, C0_obv, D0_obv, Aa_obv, Ba_obv, Ca_obv, Da_obv] = ...
        control(A, B, C, K0, topology_data{1}, topology_data{2}, p);

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

    % Run simulation
    simOut = sim(sim_model, ...
        'StartTime','0', ...
        'StopTime', num2str(p.sim_time), ...
        'FixedStep', num2str(p.time_step), ...
        'SaveOutput','on');

    % Extract signals
    t = simOut.tout;
    ge = reshape(squeeze(simOut.Global_error), [], 1);
    pe = reshape(squeeze(simOut.Position_Error_Norm), [], 1);
    ve = reshape(squeeze(simOut.Velocity_Error_Norm), [], 1);

    % Cut to minimum length
    Lmin = min([length(t), length(ge), length(pe), length(ve)]);
    time_vectors{i} = t(1:Lmin);
    global_errors{i} = ge(1:Lmin);
    pos_errors{i} = pe(1:Lmin);
    vel_errors{i} = ve(1:Lmin);

    fprintf("Topology %s → Lmin = %d, first value GE = %.4g\n", topology_name, Lmin, global_errors{i}(1));
end

%% 1. Global tracking error
figure;
hold on; grid on;
for i = 1:length(topologies)
    plot(time_vectors{i}, global_errors{i}, ...
        'LineWidth', 1.5, 'Color', colors(i,:), 'DisplayName', topologies{i});
end
xlabel('Time [s]');
ylabel('Global Tracking Error');
title('Comparison of Global Tracking Error Across Topologies');
legend('Location','northeast');
set(gca, 'FontSize', 12);

%% 2. Position tracking error
figure;
hold on; grid on;
for i = 1:length(topologies)
    plot(time_vectors{i}, pos_errors{i}, ...
        'LineWidth', 1.5, 'Color', colors(i,:), 'DisplayName', topologies{i});
end
xlabel('Time [s]');
ylabel('Position Error ∥e_{pos}∥');
title('Comparison of Position Tracking Error Across Topologies');
legend('Location','northeast');
set(gca, 'FontSize', 12);

%% 3. Velocity tracking error
figure;
hold on; grid on;
for i = 1:length(topologies)
    plot(time_vectors{i}, vel_errors{i}, ...
        'LineWidth', 1.5, 'Color', colors(i,:), 'DisplayName', topologies{i});
end
xlabel('Time [s]');
ylabel('Velocity Error ∥e_{vel}∥');
title('Comparison of Velocity Tracking Error Across Topologies');
legend('Location','northeast');
set(gca, 'FontSize', 12); 