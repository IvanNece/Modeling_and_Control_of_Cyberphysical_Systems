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
x_hat_SSO = zeros(n, Tmax);
a_hat_SSO = zeros(q, Tmax);
x_SSO = zeros(n, Tmax);
x_hat_DSSO = zeros(n, Tmax);
a_hat_DSSO = zeros(q, Tmax);
x_DSSO = zeros(n, Tmax);

% Initialize state
x_hat_SSO(:,1) = x0;
x_hat_DSSO(:,1) = x0;
x_SSO(:,1) = x0;
x_DSSO(:,1) = x0;

% Compute observer gain L for D-SSO (A-LC should be stable)
eig_target = 0.5 * ones(n,1); % Desired eigenvalues for stability
L = place(A', C', eig_target)';

% Iterate over time
for k = 1:Tmax-1

    % Osservazioni reali per entrambi i metodi
    y_SSO = C * x_SSO(:, k) + a;
    y_DSSO = C * x_DSSO(:, k) + a;

    % Predictions
    y_hat_SSO = C * x_hat_SSO(:, k) + a_hat_SSO(:, k);
    y_hat_DSSO = C * x_hat_DSSO(:, k) + a_hat_DSSO(:, k);
    
    % SSO update
    x_hat_SSO(:, k+1) = A * x_hat_SSO(:, k) - nu_SSO * A * C' * (y_hat_SSO - y_SSO);
    a_hat_SSO(:, k+1) = soft_threshold(a_hat_SSO(:, k) - nu_SSO * (y_hat_SSO - y_SSO), nu_SSO * lambda);
    x_SSO(:, k+1) = A * x_SSO(:, k);

    % D-SSO update
    x_hat_DSSO(:, k+1) = A * x_hat_DSSO(:, k) - L * (y_hat_DSSO - y_DSSO);
    a_hat_DSSO(:, k+1) = soft_threshold(a_hat_DSSO(:, k) - nu_DSSO * (y_hat_DSSO - y_DSSO), nu_DSSO * lambda);
    x_DSSO(:, k+1) = A * x_DSSO(:, k);

end

% Compute metrics
state_error_SSO = vecnorm(x_hat_SSO - x0, 2, 1) ./ vecnorm(x0, 2, 1);
state_error_DSSO = vecnorm(x_hat_DSSO - x0, 2, 1) ./ vecnorm(x0, 2, 1);
attack_error_SSO = sum(abs((a ~= 0) - (a_hat_SSO ~= 0)), 1);
attack_error_DSSO = sum(abs((a ~= 0) - (a_hat_DSSO ~= 0)), 1);
 
%Compute mean errors across iterations
state_error_SSO_mean = mean(state_error_SSO, 'omitnan');
state_error_DSSO_mean = mean(state_error_DSSO, 'omitnan');
attack_error_SSO_mean = mean(attack_error_SSO, 'omitnan');
attack_error_DSSO_mean = mean(attack_error_DSSO, 'omitnan');

% Plot State Estimation Error on log-log scale
figure;
loglog(1:Tmax, state_error_SSO, 'r', 'LineWidth', 2); hold on;
loglog(1:Tmax, state_error_DSSO, 'b', 'LineWidth', 2);
xlabel('Time (log scale)');
ylabel('State Estimation Error (log scale)');
title('State Estimation Error');
legend('SSO', 'D-SSO');
grid on;
saveas(gcf, 'StateError.png');

% Plot Attack Support Error on log-log scale
figure;
loglog(1:Tmax, attack_error_SSO, 'r', 'LineWidth', 2); hold on;
loglog(1:Tmax, attack_error_DSSO, 'b', 'LineWidth', 2);
xlabel('Time (log scale)');
ylabel('Support Attack Error (log scale)');
title('Attack Support Error');
legend('SSO', 'D-SSO');
grid on;
saveas(gcf, 'SupportError.png');

disp('Simulation complete. Results plotted.');

function s = soft_threshold(v, threshold)
    s = sign(v) .* max(abs(v) - threshold, 0);
end