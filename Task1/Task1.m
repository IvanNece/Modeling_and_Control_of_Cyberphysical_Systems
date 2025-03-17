%% GENERAZIONE DEI DATI

% Parametri del problema
n = 15;  % Numero di stati
q = 30;  % Numero di sensori (misurazioni)
h = 2;   % Numero di sensori attaccati
sigma = 1e-2; % Deviazione standard del rumore
lambda = 0.1; % Parametro di regolarizzazione

% Generazione della matrice di osservazione C ~ N(0,1)
C = randn(q, n); 

%VERSIONE 1
%nu_ista = 0.99 / norm([C, eye(q)], 2)^2; % Fattore di aggiornamento ISTA
%VERSIONE 2
nu_ista = 1 / norm(C'*C, 2); % Stabilizza il passo di aggiornamento

%VERSIONE 1 DAI DATI
%nu_ijam = 0.7; % Fattore di aggiornamento IJAM
%VERSIONE 2
nu_ijam = 1 / norm(C'*C, 2);


% Generazione del vettore stato x̃
x_true = 2 + rand(n,1); % Genera valori tra [2,3]
negative_indices = rand(n,1) > 0.5; % 50% dei valori saranno negativi
x_true(negative_indices) = -3 + rand(sum(negative_indices),1); % Genera valori tra [-3,-2] 

% Generazione del vettore di attacco ã
attack_indices = randperm(q, h); % Seleziona h sensori attaccati
a_true = zeros(q,1); % Inizializza il vettore attacchi
a_true(attack_indices) = (-1).^randi([0,1], h, 1) .* (4 + rand(h,1)); % Valori in [-5,-4] U [4,5]

% Generazione del rumore di misura η ~ N(0, σ²)
eta = sigma * randn(q,1);

% Generazione delle misurazioni y = Cx̃ + ã + η
y = C * x_true + a_true + eta;


%% IMPLEMENTAZIONE DI ISTA

function [x, a, state_errors] = ISTA(C, y, lambda, nu, max_iter, tol, x_true)
    [q, n] = size(C); % Ottiene le dimensioni della matrice C: q (misurazioni) e n (stati)

    x = zeros(n,1);   % Inizializza x con un vettore nullo (stima iniziale dello stato)
    a = zeros(q,1);   % Inizializza a con un vettore nullo (stima iniziale degli attacchi)

    state_errors = zeros(max_iter, 1); % Preallocazione per efficienza
    

    for k = 1:max_iter % Ciclo iterativo fino a max_iter o fino alla convergenza

        x_old = x; % Salva la stima precedente di x per valutare la convergenza

        %VERSIONE 1
        % Aggiornamento di x con un passo di gradiente
        %x = x_old - nu * C' * (C*x_old + a - y);

        %VERSIONE 2
        x = x - nu * C' * (C*x + a - y);

        %VERSIONE1
        % Soft-thresholding su a per promuovere la sparsità (attacchi limitati)
        %a = sign(a - nu * (C*x_old - y)) .* max(abs(a - nu * (C*x_old - y)) - lambda * nu, 0);
        
        %VERSIONE 2
        a = sign(a - nu * (C*x - y)) .* max(abs(a - nu * (C*x - y)) - lambda * nu, 0);

        % Controllo della stabilità numerica
        if any(isnan(x)) || any(isinf(x))
            warning('Divergenza in ISTA');
            break;
        end

        %VERSIONE1
        % Calcolo errore relativo in questa iterazione
        %state_errors(k) = norm(x - x_true) / norm(x_true);

        %VERSIONE2
        state_errors(k) = norm(x - x_true) / (norm(x_true) + 1e-8);

        %VERSIONE 1
        % Controllo della convergenza: se x non cambia significativamente, fermiamo l'algoritmo
        %if norm(x - x_old, 2) < tol
        %    disp("stop ISTA")

        %    break;
        %end

        %VERSIONE 2
        % Controllo della convergenza: se x non cambia significativamente, fermiamo l'algoritmo
        if norm(x - x_old, 2) < tol && k > 50 % Almeno 50 iterazioni prima di fermarsi
            disp("stop ISTA")
            break;
        end
        
    end

end


%% IMPLEMENTAZIONE DI IJAM

function [x, a, state_errors] = IJAM(C, y, lambda, nu, max_iter, tol, x_true)
    [q, n] = size(C); % Ottiene le dimensioni della matrice C: q (misurazioni) e n (stati)

    x = zeros(n,1);
    a = zeros(q,1);  
    
    %VERSIONE 1
    %C_pinv = pinv(C);  % Calcola la pseudo-inversa di C per il calcolo diretto di x
    
    %VERSIONE 2, psuedo inverse regolarizzata
    %C_pinv = pinv(C, 1e-6); 
    %C_pinv = (C' * C + 1e-6 * eye(n)) \ C'; 

    %VERSIONE 3
    C_pinv = pinv(C, 1e-3);



    state_errors = zeros(max_iter, 1); % Preallocazione

    
    for k = 1:max_iter % Ciclo iterativo fino a max_iter o fino alla convergenza
        
        x_old = x; % Salva la stima precedente di x per valutare la convergenza

        % Aggiornamento alternato di x e a
        x = C_pinv * (y - a); % Risolvf direttamente x con la pseudo-inversa di C

        %VERSIONE1
        %a = sign(a - nu * (C*x_old- y)) .* max(abs(a - nu * (C*x_old - y)) - lambda * nu, 0); % Soft-thresholding su a
        
        %VERSIONE2
         % Aggiornamento stabile di a
        a = sign(a - nu * (C*x - y)) .* max(abs(a - nu * (C*x - y)) - lambda * nu, 0);
        
        
        % Controllo della stabilità numerica
        if any(isnan(x)) || any(isinf(x))
            warning('Divergenza in IJAM: x è NaN o inf');
            break;
        end
        if any(isnan(a)) || any(isinf(a))
            warning('Divergenza in IJAM: a è NaN o inf');
            break;
        end

        %VERSIONE1
        %state_errors(k) = norm(x - x_true) / norm(x_true);

        %VERSIONE2
        state_errors(k) = norm(x - x_true) / (norm(x_true) + 1e-8);

        %VERSIONE 1
        % Controllo della convergenza: se x non cambia significativamente, fermiamo l'algoritmo
        %if norm(x - x_old, 2) < tol
        %    disp("stop Ijam")
        %    break;
        %end

        %VERSIONE 2
        % Controllo della convergenza: se x non cambia significativamente, fermiamo l'algoritmo
        if norm(x - x_old, 2) < tol && k > 50
            disp("stop Ijam")
            break;
        end

    end

    % Filtro sulle soluzioni non valide
    if state_errors(end) > 10^3
        warning('Soluzione non valida, errore troppo alto!');
    end

end


%% TEST E ANALISI

% Massimo numero di iterazioni consentite
max_iter = 3000; 

%numero di volte di esecuzione degli algoritimi
num_runs = 20;

% Soglia di convergenza:  Se la variazione tra due iterazioni successive di  x è 
% inferiore a questa soglia, consideriamo l'algoritmo convergente.
tol = 1e-10;      


% Inizializziamo le variabili per accumulare le stime finali di x e a
x_sum_ista = zeros(n,1);
a_sum_ista = zeros(q,1);
x_sum_ijam = zeros(n,1);
a_sum_ijam = zeros(q,1);

% Inizializziamo le matrici per memorizzare gli errori a ogni iterazione
state_errors_ista_all = zeros(max_iter, num_runs);
state_errors_ijam_all = zeros(max_iter, num_runs);

% ESECUZIONE MULTIPLA DEGLI ALGORITMI ISTA E IJAM

for run = 1:num_runs
    % Eseguiamo ISTA e memorizziamo i risultati
    [x_ista, a_ista, state_errors_ista] = ISTA(C, y, lambda, nu_ista, max_iter, tol, x_true);
    
    % Eseguiamo IJAM e memorizziamo i risultati
    [x_ijam, a_ijam, state_errors_ijam] = IJAM(C, y, lambda, nu_ijam, max_iter, tol, x_true);
    
    % Accumuliamo le stime ottenute nelle diverse esecuzioni
    x_sum_ista = x_sum_ista + x_ista;
    a_sum_ista = a_sum_ista + a_ista;
    
    x_sum_ijam = x_sum_ijam + x_ijam;
    a_sum_ijam = a_sum_ijam + a_ijam;
    
    % Salviamo gli errori di stato per ogni iterazione
    state_errors_ista_all(:, run) = state_errors_ista;
    state_errors_ijam_all(:, run) = state_errors_ijam;
end

% CALCOLO DELLE STIME MEDIE

% Calcoliamo la media delle stime di x e a sulle diverse esecuzioni
x_mean_ista = x_sum_ista / num_runs;
a_mean_ista = a_sum_ista / num_runs;
x_mean_ijam = x_sum_ijam / num_runs;
a_mean_ijam = a_sum_ijam / num_runs;

% CALCOLO DEGLI ERRORI FINALI

% Calcoliamo l'errore relativo dello stato stimato rispetto al valore reale
state_error_ista = norm(x_mean_ista - x_true) / norm(x_true);
state_error_ijam = norm(x_mean_ijam - x_true) / norm(x_true);

% Calcoliamo l'errore di supporto dell'attacco (percentuale di sensori attaccati errati)
support_error_ista = sum(abs((a_mean_ista ~= 0) - (a_true ~= 0))) / q;
support_error_ijam = sum(abs((a_mean_ijam ~= 0) - (a_true ~= 0))) / q;

% Stampiamo i risultati
disp(['Errore ISTA: ', num2str(state_error_ista)]);
disp(['Support Error ISTA: ', num2str(support_error_ista)]);
disp(['Errore IJAM: ', num2str(state_error_ijam)]);
disp(['Support Error IJAM: ', num2str(support_error_ijam)]);

%% PLOT DELL'ERRORE DI STATO IN FUNZIONE DELLE ITERAZIONI

% Calcoliamo la media degli errori di stato per ogni iterazione
state_errors_ista_mean = mean(state_errors_ista_all, 2, 'omitnan');
state_errors_ijam_mean = mean(state_errors_ijam_all, 2, 'omitnan');

% Creiamo il grafico della convergenza degli algoritmi
figure;
semilogy(1:max_iter, state_errors_ista_mean, 'b', 'LineWidth', 2);
hold on;
semilogy(1:max_iter, state_errors_ijam_mean, 'r', 'LineWidth', 2);
hold off;

% Etichette e titolo del grafico
xlabel('Numero di Iterazioni');
ylabel('Errore di Stato Relativo');
title('Convergenza ISTA vs IJAM');
legend('ISTA', 'IJAM');
grid on;

