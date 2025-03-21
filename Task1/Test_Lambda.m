
%% TASK 1 - ANALISI VARIABILE LAMBDA

% Parametri del problema
n = 15; q = 30; h = 2; sigma = 1e-2;
nu_ijam = 0.7;
max_iter = 3000; num_runs = 20; tol = 1e-10;

% Valori di lambda da testare
lambda_values = [0.01, 0.1, 1, 10];

for lv = 1:length(lambda_values)
    lambda = lambda_values(lv);
    fprintf('\n===== LAMBDA = %.4f =====\n', lambda);

    state_errors_ista_all = zeros(max_iter, num_runs);
    attack_errors_ista_all = zeros(max_iter, num_runs);
    state_errors_ijam_all = zeros(max_iter, num_runs);
    attack_errors_ijam_all = zeros(max_iter, num_runs);

    for run = 1:num_runs
        % Generazione dei dati
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

    % Calcolo delle medie
    state_errors_ista_mean = mean(state_errors_ista_all, 2, 'omitnan');
    attack_errors_ista_mean = mean(attack_errors_ista_all, 2, 'omitnan');
    state_errors_ijam_mean = mean(state_errors_ijam_all, 2, 'omitnan');
    attack_errors_ijam_mean = mean(attack_errors_ijam_all, 2, 'omitnan');

    % PLOT errori di stato
    figure;
    loglog(1:max_iter, state_errors_ista_mean, 'b', 'LineWidth', 2); hold on;
    loglog(1:max_iter, state_errors_ijam_mean, 'r', 'LineWidth', 2);
    xlabel('Iterations (log scale)');
    ylabel('Mean Squared State Error');
    title(['State Error - \lambda = ', num2str(lambda)]);
    legend('ISTA', 'IJAM');
    grid on;

    filename = sprintf('Plot_lambda/StateError_lambda_%.2f.png', lambda);
    saveas(gcf, filename);


    % PLOT errori di supporto
    figure;
    loglog(1:max_iter, attack_errors_ista_mean, 'b', 'LineWidth', 2); hold on;
    loglog(1:max_iter, attack_errors_ijam_mean, 'r', 'LineWidth', 2);
    xlabel('Iterations (log scale)');
    ylabel('Mean Support Attack Error');
    title(['Support Error - \lambda = ', num2str(lambda)]);
    legend('ISTA', 'IJAM');
    grid on;
    
    filename = sprintf('Plot_lambda/SupportError_lambda_%.2f.png', lambda);
    saveas(gcf, filename);

end
