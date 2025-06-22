clear; clc; close all;

% Load data
data = load('dynamic_CPS_data.mat');
A = data.A;
C = data.C;
a = data.a;
x0 = data.x0;

% Problem parameters
q = 30;
n = 15;
h = 3; % Number of sensors under attack
lambda = 0.1;

% Compute step size for SSO
G = [C eye(q)];
nu_SSO = 0.99 / (norm(G, 2)^2);
nu_DSSO = 0.7; % Given in problem statement

% Simulation parameters
Tmax = 10000;           
x_hat_SSO = x0;
a_hat_SSO = zeros(q, 1);  % CORRETTO: inizializzare come vettore
x_SSO = x0;
x_hat_DSSO = x0;
a_hat_DSSO = zeros(q, 1); % CORRETTO: inizializzare come vettore
x_DSSO = x0;

% Preallocazione vettori di errore
state_error_SSO = zeros(1, Tmax);
state_error_DSSO = zeros(1, Tmax);
attack_error_SSO = zeros(1, Tmax);
attack_error_DSSO = zeros(1, Tmax);

% Compute observer gain L for D-SSO (A-LC should be stable)
eig_target = 0.5 * ones(n,1); % Desired eigenvalues for stability
L = place(A', C', eig_target)';

% Iterate over time
for k = 1:Tmax

    % Osservazioni reali per entrambi i metodi
    y_SSO = C * x_SSO + a;
    y_DSSO = C * x_DSSO + a;

    % Predictions
    y_hat_SSO = C * x_hat_SSO + a_hat_SSO;
    y_hat_DSSO = C * x_hat_DSSO + a_hat_DSSO;
    
    % SSO update
    x_hat_SSO = A * x_hat_SSO - nu_SSO * A * C' * (y_hat_SSO - y_SSO);
    a_hat_SSO = soft_threshold(a_hat_SSO - nu_SSO * (y_hat_SSO - y_SSO), nu_SSO * lambda);
    x_SSO = A * x_SSO;

    % D-SSO update
    x_hat_DSSO = A * x_hat_DSSO - L * (y_hat_DSSO - y_DSSO);
    a_hat_DSSO = soft_threshold(a_hat_DSSO - nu_DSSO * (y_hat_DSSO - y_DSSO), nu_DSSO * lambda);
    x_DSSO = A * x_DSSO;

    % CORRETTO: Ora x_hat viene confrontato con x_SSO e x_DSSO (non x0!)
    state_error_SSO(k) = norm(x_hat_SSO - x_SSO, 2) / norm(x_SSO, 2);
    state_error_DSSO(k) = norm(x_hat_DSSO - x_DSSO, 2) / norm(x_DSSO, 2);

    % CORRETTO: confronto tra a e a_hat per errore di supporto
    attack_error_SSO(k) = sum(xor(a ~= 0, a_hat_SSO ~= 0));
    attack_error_DSSO(k) = sum(xor(a ~= 0, a_hat_DSSO ~= 0));
end

% Evita log(0) sostituendo gli zeri con eps
state_error_SSO(state_error_SSO == 0) = eps;
state_error_DSSO(state_error_DSSO == 0) = eps;
attack_error_SSO(attack_error_SSO == 0) = eps;
attack_error_DSSO(attack_error_DSSO == 0) = eps;

% --- PLOT State Estimation Error ---
figure;
loglog(1:Tmax, state_error_SSO, 'b', 'LineWidth', 1.5); hold on;
loglog(1:Tmax, state_error_DSSO, 'r', 'LineWidth', 1.5);
set(gca, 'XScale', 'log', 'YScale', 'log'); % Scala logaritmica su entrambi gli assi
xlabel('Iterations', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Relative error', 'FontSize', 12, 'FontWeight', 'bold');
title('State estimation error', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
legend({'SSO', 'D-SSO'}, 'FontSize', 12, 'Location', 'northeast');
saveas(gcf, 'StateError.png');

% --- PLOT Attack Support Error ---
figure;
loglog(1:Tmax, attack_error_SSO, 'b', 'LineWidth', 1.5); hold on;
loglog(1:Tmax, attack_error_DSSO, 'r', 'LineWidth', 1.5);
set(gca, 'XScale', 'log', 'YScale', 'linear'); % Log solo su X, lineare su Y 
xlabel('Iterations', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Support Attack Error', 'FontSize', 12, 'FontWeight', 'bold');
title('Support Attack Error', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
legend({'SSO', 'D-SSO'}, 'FontSize', 12, 'Location', 'northeast');
saveas(gcf, 'SupportError.png');

disp('Simulation complete. Results plotted.');

% Funzione di soglia soft
function s = soft_threshold(v, threshold)
    s = sign(v) .* max(abs(v) - threshold, 0);
end
