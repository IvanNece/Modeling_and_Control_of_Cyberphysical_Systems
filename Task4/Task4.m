clear; clc; close all;

%% === INIZIALIZZAZIONE ===

% Carica dati
data = load('tracking_data.mat');
A = data.A;
D = data.D;
Y = data.y;
x0 = data.xtrue0;
a_true = data.atrue;

[q, n] = size(D);        % q = 15 sensori, n = 36 celle
Tmax = size(Y, 2);       % Durata simulazione 300
lambda = 10;

% Inizializzazione
x_hat = x0;
a_hat = zeros(q, 1);

% Matrice normalizzata
G = [D eye(q)];
G = (G - mean(G))./std(G);
nu = 1 / (norm(G, 2)^2);

% Preallocazione errori
attack_support_error = zeros(1, Tmax);
state_support_error = zeros(1, Tmax);


%% === LOOP DI TRACKING ===

for k = 1:Tmax
    % === PREDIZIONE STATO CON LA DINAMICA ===
    % Usiamo la stima corrente dello stato per prevedere lo stato al tempo k+1
    % secondo la dinamica x(k+1) = A * x(k)
    x_pred = A * x_hat;

    % === OTTENIMENTO DELLA MISURA CORRENTE ===
    % Misura ricevuta dai sensori al tempo k
    y_k = Y(:,k);

    % === COSTRUZIONE DELLA STIMA COMBINATA PRIMA DELLA CORREZIONE ===
    % Combiniamo la predizione dello stato con la stima corrente degli attacchi
    % Questo è il punto di partenza prima della correzione con la misura
    z = [x_pred; a_hat];

    % === CORREZIONE VIA ISTA ===
    % Primo passo: gradiente del residuo tra previsione e misura
    z = z - nu * G' * (G * z - y_k);

    % Secondo passo: soglia soft per forzare la sparsità su stato e attacchi
    z = soft_threshold(z, nu * lambda);

    % === ESTRAZIONE DELLE STIME CORRETTE ===
    % Aggiorniamo lo stato stimato (x_hat) e l'attacco stimato (a_hat)
    % Queste verranno usate per la predizione successiva
    x_hat = z(1:n);
    a_hat = z(n+1:end);

    % === VALUTAZIONE ERRORI DI SUPPORTO ===
    epsilon = 1;

    % Stima approssimata del supporto vero dello stato (target in cella massima)
    x_true_sparse = zeros(n,1);
    x_true_sparse(find(x_hat == max(x_hat))) = 1;

    % Confronto tra attacchi veri e stimati (supporto)
    attack_support_error(k) = sum(xor(abs(a_true) >= epsilon, abs(a_hat) >= epsilon));

    % Confronto tra supporto stimato dello stato e quello approssimato
    state_support_error(k) = sum(abs((abs(x_hat) >= epsilon) - (abs(x_true_sparse) >= epsilon)));
end


%% === PLOT E SALVATAGGIO ===

% Plot errore supporto stato
figure;
plot(1:Tmax, state_support_error, 'b', 'LineWidth', 2);
xlabel('Time step', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Support State Error', 'FontSize', 12, 'FontWeight', 'bold');
title('Support State Error over Time', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
saveas(gcf, 'SupportStateError_Task4.png');

% Plot errore supporto attacco
figure;
plot(1:Tmax, attack_support_error, 'r', 'LineWidth', 2);
xlabel('Time step', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Support Attack Error', 'FontSize', 12, 'FontWeight', 'bold');
title('Support Attack Error over Time', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
saveas(gcf, 'SupportAttackError_Task4.png');

disp("Tracking completo. Plot salvati.");

%% === FUNZIONE DI SOGLIA SOFT ===
function s = soft_threshold(v, threshold)
    s = sign(v) .* max(abs(v) - threshold, 0);
end
