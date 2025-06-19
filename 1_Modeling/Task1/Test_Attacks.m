%% TASK 1 - ANALISI VARIAZIONE NUMERO DI SENSORI ATTACCATI (h)

% Parametri base
n = 15; q = 30; sigma = 1e-2;
lambda = 0.1;
max_iter = 1e4; num_runs = 20; tol = 0;

% Creazione cartella per i plot
if ~exist('NewPlots/Plot_attacks', 'dir')
    mkdir('NewPlots/Plot_attacks');
end

% Valori di h da testare
h_values = [ 3, 5, 10, 20];

for hv = 1:length(h_values)
    h = h_values(hv);
    fprintf('\n===== TESTING h = %d sensors under attack =====\n', h);

    % Preallocazione errori
    state_errors_ista_all = zeros(max_iter, num_runs);
    attack_errors_ista_all = zeros(max_iter, num_runs);
    state_errors_ijam_all = zeros(max_iter, num_runs);
    attack_errors_ijam_all = zeros(max_iter, num_runs);

    for run = 1:num_runs
        % Generazione dati
        C = randn(q, n);
        x_true = 2 + rand(n,1);
        neg_idx = rand(n,1) > 0.5;
        x_true(neg_idx) = -3 + rand(sum(neg_idx),1);

        a_true = zeros(q,1);
        attack_idx = randperm(q, h);
        a_true(attack_idx) = (-1).^randi([0,1], h, 1) .* (4 + rand(h,1));

        eta = sigma * randn(q,1);
        y = C * x_true + a_true + eta;

        G = [C, eye(q)];
        nu_ista = 1 / norm(G, 2)^2;
        nu_ijam = 0.7;

        % Esecuzione algoritmi
        [~, ~, se_ista, ae_ista] = ISTA(C, y, lambda, nu_ista, max_iter, tol, x_true, a_true);
        [~, ~, se_ijam, ae_ijam] = IJAM(C, y, lambda, nu_ijam, max_iter, tol, x_true, a_true);

        % Salvataggio errori
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

    % === PLOT STATE ERROR
    figure;
    semilogx(1:max_iter, state_errors_ista_mean, 'b', 'LineWidth', 1); hold on;
    semilogx(1:max_iter, state_errors_ijam_mean, 'r', 'LineWidth', 1);
    xlabel('Iterations (log scale)', 'Interpreter', 'latex');
    ylabel('Mean Squared State Error', 'Interpreter', 'latex');
    title(['State Estimation Error - $h$ = ', num2str(h)], 'Interpreter', 'latex');
    legend('ISTA', 'IJAM');
    grid on;

    filename = sprintf('NewPlots/Plot_attacks/StateError_h_%d.png', h);
    saveas(gcf, filename);

    % === PLOT SUPPORT ERROR
    figure;
    semilogx(1:max_iter, attack_errors_ista_mean, 'b', 'LineWidth', 1); hold on;
    semilogx(1:max_iter, attack_errors_ijam_mean, 'r', 'LineWidth', 1);
    xlabel('Iterations (log scale)', 'Interpreter', 'latex');
    ylabel('Mean Support Attack Error', 'Interpreter', 'latex');
    title(['Support Attack Error - $h$ = ', num2str(h)], 'Interpreter', 'latex');
    legend('ISTA', 'IJAM');
    grid on;

    filename = sprintf('NewPlots/Plot_attacks/SupportError_h_%d.png', h);
    saveas(gcf, filename);
end
