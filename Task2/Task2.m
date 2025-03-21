clear; clc; close all;

% 1. Caricare i dati
data = load('localization_data.mat');
D = data.D; 
y = data.y;

% 2. Creare la matrice G = [D I] e normalizzarla
[q, n] = size(D); 
G = [D eye(q)]; % Concatenazione di D con matrice identità
G = (G - mean(G, 1)) ./ std(G, 0, 1); % Normalizzazione (media 0, varianza 1)

% 3. Impostare i parametri
lambda = 10;
nu = 1 / (norm(G, 2)^2); % Passo ISTA
max_iter = 500;
tol = 1e-6; % Tolleranza per la convergenza

[x, a] = ISTAtarget(G, y, lambda, nu, max_iter);

% 5. Estrarre i risultati
[~, target_location] = max(abs(x));  % Cella con il valore massimo di x
attacked_sensors = find(abs(a) > 1e-3); % Supporto di a (sensori attaccati)

% 6. Visualizzare i risultati
disp('Posizione stimata del target:');
disp(target_location);

disp('Sensori attaccati identificati:');
disp(attacked_sensors);
