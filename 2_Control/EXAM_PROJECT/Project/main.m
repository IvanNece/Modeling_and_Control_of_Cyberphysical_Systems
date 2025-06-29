% === MAIN SCRIPT ===
clc; clear; close all;

%% === DEFINIZIONE DEL MODELLO DELL'AGENTE ===
[A, B, C, D] = plant_definition();

%% === GENERAZIONE DELLE TOPOLOGIE ===
topos = generate_topology();

% Seleziona una topologia da usare (puoi cambiare tra 'line', 'ring', 'full')
selected = 'ring';
L = topos.(selected){1};
G = topos.(selected){2};
adj = topos.(selected){3};

% Mostra cosa stai usando
fprintf("→ Topologia selezionata: %s\n", selected);
disp("Laplaciano L:"); disp(L);
disp("Pinning G:"); disp(G);
disp("Matrice di adiacenza (adj):"); disp(adj);


%% === DESIGN DEL CONTROLLORE ===
% Scelta matrici Q e R per l'LQR
Q = eye(2);      % penalizza posizione e velocità
R = 1;           % penalizza sforzo di controllo

% Calcolo guadagno K
K = design_K(A, B, Q, R);
disp("Matrice di guadagno K:"); disp(K);

%% === DESIGN DELL'OSSERVATORE ===
% Scelta matrici Qobs e Robs per l’osservatore
Qobs = eye(2);    % penalizza errore sugli stati
Robs = 1;         % penalizza errore sulle uscite

% Calcolo guadagno osservatore F
F = design_F(A, C, Qobs, Robs);
disp("Matrice di guadagno F:"); disp(F);

%% === SIMULAZIONE LEADER ===
ref_type = 'constant';   % 'constant' | 'ramp' | 'sine'
T = 10;
dt = 0.01;

[x0_hist, u0_hist, t] = simulate_leader(A, B, C, ref_type, T, dt);

% Plot posizione del leader
figure;
plot(t, x0_hist(1,:), 'LineWidth', 1.5);
title(['Leader - Posizione (riferimento: ', ref_type, ')']);
xlabel('Tempo [s]'); ylabel('Posizione [m]');
grid on;
