%% TASK 1 - ANALISI VARIAZIONE DI LAMBDA

% Parametri del problema
n = 15; q = 30; h = 2; sigma = 1e-2;
nu_ijam = 0.7;
max_iter = 1e4; num_runs = 20; tol = 0;

% Vettore dei lambda da testare
lambda_values = [0.01, 0.1, 1, 10];

% Creazione cartella se non esiste
if ~exist('NewPlots/Plot_lambda', 'dir')
    mkdir('NewPlots/Plot_lambda');
end

for lv = 1:length(lambda_values)
    lambda = lambda_values(lv);
    fprintf('\n===== LAMBDA = %.4f =====\n', lambda);

    state_errors_ista_all = zeros(max_iter, num_runs);
    attack_errors_ista_all = zeros(max_iter, num_runs);
    state_errors_ijam_all = zeros(max_iter, num_runs);
    attack_errors_ijam_all = zeros(max_iter, num_runs);

    for run = 1:num_runs
        % Generazione dati random
        C = randn(q, n);
        x_true = 2 + rand(n,1);
        negative_indices = rand(n,1) > 0.5;
        x_true(negative_indices) = -3 + rand(sum(negative_indices),1);
        attack_indices = randperm(q, h);
        a_true = zeros(q,1);
        a_true(attack_indices) = (-1).^randi([0,1], h, 1) .* (4 + rand(h,1));
        eta = sigma * randn(q,1);
        y = C * x_true + a_true + eta;

        G = [C, eye(q)];
        nu_ista = 1 / norm(G, 2)^2;

        [~, ~, se_ista, ae_ista] = ISTA(C, y, lambda, nu_ista, max_iter, tol, x_true, a_true);
        [~, ~, se_ijam, ae_ijam] = IJAM(C, y, lambda, nu_ijam, max_iter, tol, x_true, a_true);

        state_errors_ista_all(:, run) = se_ista;
        attack_errors_ista_all(:, run) = ae_ista;
        state_errors_ijam_all(:, run) = se_ijam;
        attack_errors_ijam_all(:, run) = ae_ijam;
    end

    % Calcolo medie
    state_errors_ista_mean = mean(state_errors_ista_all, 2, 'omitnan');
    attack_errors_ista_mean = mean(attack_errors_ista_all, 2, 'omitnan');
    state_errors_ijam_mean = mean(state_errors_ijam_all, 2, 'omitnan');
    attack_errors_ijam_mean = mean(attack_errors_ijam_all, 2, 'omitnan');

    % === PLOT STATE ESTIMATION ERROR (x log, y lineare)
    figure;
    semilogx(1:max_iter, state_errors_ista_mean, 'b', 'LineWidth', 1); hold on;
    semilogx(1:max_iter, state_errors_ijam_mean, 'r', 'LineWidth', 1);
    xlabel('Iterations (log scale)');
    ylabel('Mean Squared State Error');
    title(['State Estimation Error - \lambda = ', num2str(lambda)]);
    legend('ISTA', 'IJAM');
    grid on;

    filename = sprintf('NewPlots/Plot_lambda/StateError_lambda_%.2f.png', lambda);
    saveas(gcf, filename);

    % === PLOT SUPPORT ERROR (x log, y lineare)
    figure;
    semilogx(1:max_iter, attack_errors_ista_mean, 'b', 'LineWidth', 1); hold on;
    semilogx(1:max_iter, attack_errors_ijam_mean, 'r', 'LineWidth', 1);
    xlabel('Iterations (log scale)');
    ylabel('Mean Support Attack Error');
    title(['Support Attack Error - \lambda = ', num2str(lambda)]);
    legend('ISTA', 'IJAM');
    grid on;

    filename = sprintf('NewPlots/Plot_lambda/SupportError_lambda_%.2f.png', lambda);
    saveas(gcf, filename);
end
