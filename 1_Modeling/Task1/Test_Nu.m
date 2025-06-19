%% TASK 1 - ANALISI VARIAZIONE DI NU

% Parametri base
n = 15; q = 30; h = 2; sigma = 1e-2;
lambda = 0.1;
max_iter = 1e4; num_runs = 20; tol = 0;

% Fattori moltiplicativi per nu = factor / ||G||^2
nu_factors = [0.01, 0.1, 0.5, 1.0];

% Creazione cartella se non esiste
if ~exist('NewPlots/Plot_nu', 'dir')
    mkdir('NewPlots/Plot_nu');
end

for nv = 1:length(nu_factors)
    factor = nu_factors(nv);
    fprintf('\n===== NU FACTOR = %.3f =====\n', factor);

    % Preallocazione errori
    state_errors_ista_all = zeros(max_iter, num_runs);
    attack_errors_ista_all = zeros(max_iter, num_runs);
    state_errors_ijam_all = zeros(max_iter, num_runs);
    attack_errors_ijam_all = zeros(max_iter, num_runs);

    for run = 1:num_runs
        % Generazione dati casuali
        C = randn(q, n);
        x_true = 2 + rand(n,1);
        neg_idx = rand(n,1) > 0.5;
        x_true(neg_idx) = -3 + rand(sum(neg_idx),1);
        attack_idx = randperm(q, h);
        a_true = zeros(q,1);
        a_true(attack_idx) = (-1).^randi([0,1], h, 1) .* (4 + rand(h,1));
        y = C * x_true + a_true + sigma * randn(q,1);

        % Adattamento step-size
        G = [C, eye(q)];
        nu = factor / norm(G, 2)^2;

        [~, ~, se_ista, ae_ista] = ISTA(C, y, lambda, nu, max_iter, tol, x_true, a_true);
        [~, ~, se_ijam, ae_ijam] = IJAM(C, y, lambda, nu, max_iter, tol, x_true, a_true);

        % Salvataggio errori
        state_errors_ista_all(:, run) = se_ista;
        attack_errors_ista_all(:, run) = ae_ista;
        state_errors_ijam_all(:, run) = se_ijam;
        attack_errors_ijam_all(:, run) = ae_ijam;
    end

    % Medie
    state_errors_ista_mean = mean(state_errors_ista_all, 2, 'omitnan');
    attack_errors_ista_mean = mean(attack_errors_ista_all, 2, 'omitnan');
    state_errors_ijam_mean = mean(state_errors_ijam_all, 2, 'omitnan');
    attack_errors_ijam_mean = mean(attack_errors_ijam_all, 2, 'omitnan');

    % === PLOT STATE ERROR (x log, y lineare)
    figure;
    semilogx(1:max_iter, state_errors_ista_mean, 'b', 'LineWidth', 1); hold on;
    semilogx(1:max_iter, state_errors_ijam_mean, 'r', 'LineWidth', 1);
    xlabel('Iterations (log scale)');
    ylabel('Mean Squared State Error');
    title(['State Estimation Error - \nu = ', num2str(factor)]);
    legend('ISTA', 'IJAM');
    grid on;

    filename = sprintf('NewPlots/Plot_nu/StateError_nu_%.3f.png', factor);
    saveas(gcf, filename);

    % === PLOT SUPPORT ERROR (x log, y lineare)
    figure;
    semilogx(1:max_iter, attack_errors_ista_mean, 'b', 'LineWidth', 1); hold on;
    semilogx(1:max_iter, attack_errors_ijam_mean, 'r', 'LineWidth', 1);
    xlabel('Iterations (log scale)');
    ylabel('Mean Support Attack Error');
    title(['Support Attack Error - \nu = ', num2str(factor)]);
    legend('ISTA', 'IJAM');
    grid on;

    filename = sprintf('NewPlots/Plot_nu/SupportError_nu_%.3f.png', factor);
    saveas(gcf, filename);
end
