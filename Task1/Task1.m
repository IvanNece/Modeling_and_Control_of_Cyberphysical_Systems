%% GENERAZIONE DEI DATI

% Parametri del problema
n = 15;  % Numero di stati
q = 30;  % Numero di sensori (misurazioni)
h = 2;   % Numero di sensori attaccati
sigma = 1e-2; % Deviazione standard del rumore
lambda = 0.1; % Parametro di regolarizzazione
nu_ista = 0.99 / norm([randn(q, n), eye(q)], 2)^2; % Fattore di aggiornamento ISTA
nu_ijam = 0.7; % Fattore di aggiornamento IJAM

% Generazione della matrice di osservazione C ~ N(0,1)
C = randn(q, n); 

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

function [x_est, a_est] = ISTA(C, y, lambda, nu, max_iter, tol)
    [q, n] = size(C); % Ottiene le dimensioni della matrice C: q (misurazioni) e n (stati)
    x = zeros(n,1);   % Inizializza x con un vettore nullo (stima iniziale dello stato)
    a = zeros(q,1);   % Inizializza a con un vettore nullo (stima iniziale degli attacchi)

    for k = 1:max_iter % Ciclo iterativo fino a max_iter o fino alla convergenza
        x_old = x; % Salva la stima precedente di x per valutare la convergenza
        
        % Aggiornamento di x con un passo di gradiente
        x = x - nu * C' * (C*x + a - y);
        
        % Soft-thresholding su a per promuovere la sparsità (attacchi limitati)
        a = sign(a - nu * (C*x - y)) .* max(abs(a - nu * (C*x - y)) - lambda * nu, 0);
        
        % Controllo della convergenza: se x non cambia significativamente, fermiamo l'algoritmo
        if norm(x - x_old, 2) < tol
            break;
        end
    end
    
    % Uscita: le stime finali di x (stato) e a (attacchi)
    x_est = x;
    a_est = a;
end


%% IMPLEMENTAZIONE DI IJAM

function [x_est, a_est] = IJAM(C, y, lambda, nu, max_iter, tol)
    [q, n] = size(C); % Ottiene le dimensioni della matrice C: q (misurazioni) e n (stati)
    x = zeros(n,1);   % Inizializza x con un vettore nullo (stima iniziale dello stato)
    a = zeros(q,1);   % Inizializza a con un vettore nullo (stima iniziale degli attacchi)
    C_pinv = pinv(C);  % Calcola la pseudo-inversa di C per il calcolo diretto di x

    for k = 1:max_iter % Ciclo iterativo fino a max_iter o fino alla convergenza
        x_old = x; % Salva la stima precedente di x per valutare la convergenza
        
        % Aggiornamento alternato di x e a
        x = C_pinv * (y - a); % Risolve direttamente x con la pseudo-inversa di C
        a = sign(a - nu * (C*x - y)) .* max(abs(a - nu * (C*x - y)) - lambda * nu, 0); % Soft-thresholding su a
        
        % Controllo della convergenza: se x non cambia significativamente, fermiamo l'algoritmo
        if norm(x - x_old, 2) < tol
            break;
        end
    end
    
    % Uscita: le stime finali di x (stato) e a (attacchi)
    x_est = x;
    a_est = a;
end


%% TEST E ANALISI

% Massimo numero di iterazioni consentite
max_iter = 1000; 
% Soglia di convergenza:  Se la variazione tra due iterazioni successive di  x è 
% inferiore a questa soglia, consideriamo l'algoritmo convergente.
tol = 1e-10;      

% Eseguire ISTA per stimare x e a
[x_ista, a_ista] = ISTA(C, y, lambda, nu_ista, max_iter, tol);

% Eseguire IJAM per stimare x e a
[x_ijam, a_ijam] = IJAM(C, y, lambda, nu_ijam, max_iter, tol);

% Calcolo dell'errore di stima dello stato per ISTA
state_error_ista = norm(x_ista - x_true) / norm(x_true);

% Calcolo dell'errore di stima dello stato per IJAM
state_error_ijam = norm(x_ijam - x_true) / norm(x_true);

% Visualizzazione dei risultati
disp(['Errore ISTA: ', num2str(state_error_ista)]);
disp(['Errore IJAM: ', num2str(state_error_ijam)]);

