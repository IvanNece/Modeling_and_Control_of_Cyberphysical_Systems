clear; clc; close all;

%% === INIZIALIZZAZIONE ===

% Carica dati
data = load('tracking_data.mat');
A = data.A;
D = data.D;
Y = data.y;
x0 = data.xtrue0;
a_true = data.atrue;

[q, n] = size(D);        % q = 15 sensori, n = 36 celle
Tmax = size(Y, 2);       % Durata simulazione 300
lambda = 10;

% Inizializzazione
x_hat = x0;
a_hat = zeros(q, 1);

% Matrice normalizzata per ISTA
G = [D eye(q)];
G = (G - mean(G))./std(G);
nu = 1 / (norm(G, 2)^2);

% Preallocazione errori
attack_support_error = zeros(1, Tmax);
state_support_error = zeros(1, Tmax);

%% === ANALISI OSSERVABILITÀ SISTEMA AUMENTATO ===

A_aug = blkdiag(A, eye(q));  % Matrice dinamica aumentata (51x51)
G_noNorm = [D eye(q)];       % Matrice G non normalizzata
O = [];

for i = 0:(n+q-1)
    O = [O; G_noNorm * (A_aug^i)];
end

rank_O = rank(O);
fprintf('Rank of augmented observability matrix: %d (expected max: %d)\n', rank_O, n + q);

%% === LOOP DI TRACKING ===

for k = 1:Tmax
    % Predizione stato
    x_pred = A * x_hat;

    % Misura corrente
    y_k = Y(:,k);

    % Stima congiunta stato-attacco
    z = [x_pred; a_hat];

    % Correzione ISTA
    z = z - nu * G' * (G * z - y_k);
    z = soft_threshold(z, nu * lambda);

    % Aggiornamento stime
    x_hat = z(1:n);
    a_hat = z(n+1:end);

    % Calcolo supporto stimato (stato)
    epsilon = 1;
    x_true_sparse = zeros(n,1);
    x_true_sparse(find(x_hat == max(x_hat))) = 1;

    % Errori di supporto
    attack_support_error(k) = sum(xor(abs(a_true) >= epsilon, abs(a_hat) >= epsilon));
    state_support_error(k) = sum(abs((abs(x_hat) >= epsilon) - (abs(x_true_sparse) >= epsilon)));
end

%% === PLOT E SALVATAGGIO ===

% Stato
figure;
plot(1:Tmax, state_support_error, 'b', 'LineWidth', 1.5);
xlabel('Time step', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Support State Error', 'FontSize', 12, 'FontWeight', 'bold');
title('Support State Error over Time', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
saveas(gcf, 'SupportStateError_Task4.png');

% Attacco
figure;
plot(1:Tmax, attack_support_error, 'r', 'LineWidth', 1.5);
xlabel('Time step', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Support Attack Error', 'FontSize', 12, 'FontWeight', 'bold');
title('Support Attack Error over Time', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
saveas(gcf, 'SupportAttackError_Task4.png');

disp("Tracking completo. Plot salvati.");

%% === FUNZIONE DI SOGLIA SOFT ===
function s = soft_threshold(v, threshold)
    s = sign(v) .* max(abs(v) - threshold, 0);
end
