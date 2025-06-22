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

figure;
stem(1:length(x), abs(x), 'filled', 'LineWidth', 1);
hold on;
[~, idx_max] = max(abs(x));
stem(idx_max, abs(x(idx_max)), 'r', 'filled', 'LineWidth', 2); % massimo in rosso
xlabel('Cella');
ylabel('x');
title('Estimated Target Location');
legend('Estimated values', 'Maximum (target)');
grid on;
saveas(gcf, fullfile('Plots', 'Estimated_Target_Location.png'));

% === GRAFICO 2: Sensori attaccati stimati ===
figure;
stem(1:length(a), abs(a), 'filled', 'LineWidth', 1);
hold on;
threshold = 1e-3;
highlighted = find(abs(a) > threshold);
stem(highlighted, abs(a(highlighted)), 'r', 'filled', 'LineWidth', 2); % valori sopra soglia
xlabel('Sensor Index');
ylabel('a');
title('Estimated Attack Vector');
legend('Estimated values', 'Detected attacks');
grid on;
saveas(gcf, fullfile('Plots', 'Estimated_Attack_Vector.png'));

% === Stampa dei risultati ===
[~, target_location] = max(abs(x));  % Cella con il valore massimo di x
attacked_sensors = find(abs(a) > threshold); % Supporto di a (sensori attaccati)

disp('Posizione stimata del target:');
disp(target_location);

disp('Sensori attaccati identificati:');
disp(attacked_sensors);