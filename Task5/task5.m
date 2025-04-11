clear; clc; close all


% Carica dati
data = load("localization_data.mat");
D = data.D;
y = data.y;
[q, n] = size(D);
G = [D eye(q)];
G = (G - mean(G, 1)) ./ std(G, 0, 1); % Normalizzazione (media 0, varianza 1)

% Parametri
lambda = 1;
nu = 0.01 / (norm(G, 2)^2); % Passo DISTA
tol = 1e-8;

% Ring topology
Q_ring = load("Q_ring.mat").Q;
[x_r, a_r] = dista(G, y, Q_ring, lambda, nu, tol);
disp("RING TOPOLOGY:");
[~, target_r] = max(abs(x_r));
disp("Target location:"); disp(target_r);
disp("Attacked sensors:"); disp(find(abs(a_r) > 1e-3)');

disp("-------------------------------------------------------------------")
% Star topology
Q_star = load("Q_star.mat").Q;
[x_s, a_s] = dista_star(G, y, Q_star, lambda, nu, tol);
disp("STAR TOPOLOGY:");
[~, target_s] = max(abs(x_s));
disp("Target location:"); disp(target_s);
disp("Attacked sensors:"); disp(find(abs(a_s) > 1)');


