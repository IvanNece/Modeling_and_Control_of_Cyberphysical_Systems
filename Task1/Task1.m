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
state_errors_ijam_all = zeros(max_iter, num_runs);

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
    
    [x_ista, a_ista, state_errors_ista] = ISTA(C, y, lambda, nu_ista, max_iter, tol, x_true);
    [x_ijam, a_ijam, state_errors_ijam] = IJAM(C, y, lambda, nu_ijam, max_iter, tol, x_true);
    
    x_sum_ista = x_sum_ista + x_ista;
    a_sum_ista = a_sum_ista + a_ista;
    x_sum_ijam = x_sum_ijam + x_ijam;
    a_sum_ijam = a_sum_ijam + a_ijam;
    
    state_errors_ista_all(:, run) = state_errors_ista;
    state_errors_ijam_all(:, run) = state_errors_ijam;
end

% Calcolo delle stime medie
x_mean_ista = x_sum_ista / num_runs;
a_mean_ista = a_sum_ista / num_runs;
x_mean_ijam = x_sum_ijam / num_runs;
a_mean_ijam = a_sum_ijam / num_runs;

% Calcolo errori finali
state_error_ista = norm(x_mean_ista - x_true) / norm(x_true);
state_error_ijam = norm(x_mean_ijam - x_true) / norm(x_true);
support_error_ista = sum(abs((a_mean_ista ~= 0) - (a_true ~= 0))) / q;
support_error_ijam = sum(abs((a_mean_ijam ~= 0) - (a_true ~= 0))) / q;

% Visualizzazione risultati
disp(['Errore ISTA: ', num2str(state_error_ista)]);
disp(['Support Error ISTA: ', num2str(support_error_ista)]);
disp(['Errore IJAM: ', num2str(state_error_ijam)]);
disp(['Support Error IJAM: ', num2str(support_error_ijam)]);

% PLOT
state_errors_ista_mean = mean(state_errors_ista_all, 2, 'omitnan');
state_errors_ijam_mean = mean(state_errors_ijam_all, 2, 'omitnan');

figure;
semilogy(1:max_iter, state_errors_ista_mean, 'b', 'LineWidth', 2);
hold on;
semilogy(1:max_iter, state_errors_ijam_mean, 'r', 'LineWidth', 2);
hold off;
xlabel('Numero di Iterazioni');
ylabel('Errore di Stato Relativo');
title('Convergenza ISTA vs IJAM');
legend('ISTA', 'IJAM');
grid on;