%% TASK 1: Secure State Estimation

% Parametri del problema
n = 15;  % Numero di stati
q = 30;  % Numero di sensori (misurazioni)
h = 2;   % Numero di sensori attaccati
sigma = 1e-2; % Deviazione standard del rumore
lambda = 0.1; % Parametro di regolarizzazione

% Parametri di test
max_iter = 3000;
num_runs = 20;
tol = 1e-10;

% ESECUZIONE MULTIPLA DEGLI ALGORITMI
x_sum_ista = zeros(n,1);
a_sum_ista = zeros(q,1);
x_sum_ijam = zeros(n,1);
a_sum_ijam = zeros(q,1);
state_errors_ista_all = zeros(max_iter, num_runs);
attack_errors_ista_all = zeros(max_iter, num_runs);
state_errors_ijam_all = zeros(max_iter, num_runs);
attack_errors_ijam_all = zeros(max_iter, num_runs);

for run = 1:num_runs
    % Rigenerazione della matrice di osservazione C ~ N(0,1)
    C = randn(q, n);
    
    % Generazione del vettore stato x̃
    x_true = 2 + rand(n,1); 
    negative_indices = rand(n,1) > 0.5; 
    x_true(negative_indices) = -3 + rand(sum(negative_indices),1); 
    
    % Generazione del vettore di attacco ã
    attack_indices = randperm(q, h);
    a_true = zeros(q,1);
    a_true(attack_indices) = (-1).^randi([0,1], h, 1) .* (4 + rand(h,1));
    
    % Generazione del rumore di misura η ~ N(0, σ²)
    eta = sigma * randn(q,1);
    
    % Generazione delle misurazioni y = Cx̃ + ã + η
    y = C * x_true + a_true + eta;
    
    % Ricalcolo del parametro G e del passo di aggiornamento nu_ISTA
    G = [C, eye(q)];
    nu_ista = 1 / norm(G, 2)^2;
    nu_ijam = 0.7;
    
    [x_ista, a_ista, se_ista, ae_ista] = ISTA(C, y, lambda, nu_ista, max_iter, tol, x_true, a_true);
    [x_ijam, a_ijam, se_ijam, ae_ijam] = IJAM(C, y, lambda, nu_ijam, max_iter, tol, x_true, a_true);

    state_errors_ista_all(:, run) = se_ista;
    attack_errors_ista_all(:, run) = ae_ista;
    state_errors_ijam_all(:, run) = se_ijam;
    attack_errors_ijam_all(:, run) = ae_ijam;
end

% Calcolo degli errori medi finali (ultima iterazione)
state_error_ista = mean(state_errors_ista_all(end, :)); 
state_error_ijam = mean(state_errors_ijam_all(end, :));

support_error_ista = mean(attack_errors_ista_all(end, :)); 
support_error_ijam = mean(attack_errors_ijam_all(end, :));


disp(['Errore ISTA: ', num2str(state_error_ista)]);
disp(['Support Error ISTA: ', num2str(support_error_ista)]);
disp(['Errore IJAM: ', num2str(state_error_ijam)]);
disp(['Support Error IJAM: ', num2str(support_error_ijam)]);


state_errors_ista_mean = mean(state_errors_ista_all, 2, 'omitnan');
attack_errors_ista_mean = mean(attack_errors_ista_all, 2, 'omitnan');
state_errors_ijam_mean = mean(state_errors_ijam_all, 2, 'omitnan');
attack_errors_ijam_mean = mean(attack_errors_ijam_all, 2, 'omitnan');

figure;
loglog(1:max_iter, state_errors_ista_mean, 'b', 'LineWidth', 2); hold on;
loglog(1:max_iter, state_errors_ijam_mean, 'r', 'LineWidth', 2);
xlabel('Iterations (log scale)');
ylabel('Mean Squared State Error');
title('State Estimation Error');
legend('ISTA', 'IJAM');
grid on;

figure;
loglog(1:max_iter, attack_errors_ista_mean, 'b', 'LineWidth', 2); hold on;
loglog(1:max_iter, attack_errors_ijam_mean, 'r', 'LineWidth', 2);
xlabel('Iterations (log scale)');
ylabel('Mean Support Attack Error');
title('Support Attack Error');
legend('ISTA', 'IJAM');
grid on;

