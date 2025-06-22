clear; clc; close all;

% Load data
data = load('dynamic_CPS_data.mat');
A = data.A;
C_original = data.C;
a = data.a;
x0 = data.x0;

% Parameters
n = 15;
q = 30;
lambda = 0.1;
nu_SSO = 0.99 / (norm([C_original eye(q)], 2)^2);
nu_DSSO = 0.7;
Tmax = 1e5;
k_refine = 100;  % Iterazione in cui "blocchiamo" il supporto attacco

% Inizializzazioni
x_SSO = x0; x_hat_SSO = x0; a_hat_SSO = zeros(q,1);
x_DSSO = x0; x_hat_DSSO = x0; a_hat_DSSO = zeros(q,1);
C_SSO = C_original; C_DSSO = C_original;

state_error_SSO = zeros(1, Tmax);
state_error_DSSO = zeros(1, Tmax);
attack_error_SSO = zeros(1, Tmax);
attack_error_DSSO = zeros(1, Tmax);

% Calcolo L iniziale
L = place(A', C_DSSO', 0.5 * ones(n,1))';

for k = 1:Tmax

    % --- SWITCH to refined model at iteration k_refine ---
    if k == k_refine
        % Stima supporto attacco
        supp_SSO = find(abs(a_hat_SSO) > 1e-3);
        supp_DSSO = find(abs(a_hat_DSSO) > 1e-3);

        % Azzera righe di C
        C_SSO(supp_SSO, :) = 0;
        C_DSSO(supp_DSSO, :) = 0;

        % Ricomputa L per D-SSO
        L = place(A', C_DSSO', 0.5 * ones(n,1))';
    end

    % --- Output measurements ---
    y_SSO = C_SSO * x_SSO + a;
    y_DSSO = C_DSSO * x_DSSO + a;

    y_hat_SSO = C_SSO * x_hat_SSO + a_hat_SSO;
    y_hat_DSSO = C_DSSO * x_hat_DSSO + a_hat_DSSO;

    % --- Updates ---
    x_hat_SSO = A * x_hat_SSO - nu_SSO * A * C_SSO' * (y_hat_SSO - y_SSO);
    a_hat_SSO = soft_threshold(a_hat_SSO - nu_SSO * (y_hat_SSO - y_SSO), nu_SSO * lambda);
    x_SSO = A * x_SSO;

    x_hat_DSSO = A * x_hat_DSSO - L * (y_hat_DSSO - y_DSSO);
    a_hat_DSSO = soft_threshold(a_hat_DSSO - nu_DSSO * (y_hat_DSSO - y_DSSO), nu_DSSO * lambda);
    x_DSSO = A * x_DSSO;

    % --- Errors ---
    state_error_SSO(k) = norm(x_hat_SSO - x_SSO) / norm(x_SSO);
    state_error_DSSO(k) = norm(x_hat_DSSO - x_DSSO) / norm(x_DSSO);
    attack_error_SSO(k) = sum(xor(a ~= 0, a_hat_SSO ~= 0));
    attack_error_DSSO(k) = sum(xor(a ~= 0, a_hat_DSSO ~= 0));
end

% Plot state estimation error (log-log)
figure;
loglog(1:Tmax, state_error_SSO, 'b', 'LineWidth', 1.5); hold on;
loglog(1:Tmax, state_error_DSSO, 'r', 'LineWidth', 1.5);
xlabel('Iterations'); ylabel('Relative state error');
legend('SSO', 'D-SSO');
title('State estimation error');
grid on;
saveas(gcf, 'Refined_State_Error.png');


% Plot support attack error
figure;
semilogx(1:Tmax, attack_error_SSO, 'b', 'LineWidth', 1.5); hold on;
semilogx(1:Tmax, attack_error_DSSO, 'r', 'LineWidth', 1.5);
xlabel('Iterations'); ylabel('Support attack error');
legend('SSO', 'D-SSO');
title('Support attack error');
grid on;
saveas(gcf, 'Refined_Support_Error.png');

% --- Soft threshold function ---
function s = soft_threshold(v, t)
    s = sign(v) .* max(abs(v) - t, 0);
end
