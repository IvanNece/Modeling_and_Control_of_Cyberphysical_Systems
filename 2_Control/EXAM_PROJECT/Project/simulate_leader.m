function [x0_hist, u0_hist, t] = simulate_leader(A, B, C, ref_type, T, dt)
% SIMULATE_LEADER - Simula il leader (S0) controllato per generare la
% traiettoria di riferimento costante, rampa o sinusoidale.
%
% Il leader è stabilizzato tramite controllo a feedback di stato (u = -Kx̂)
% e lo stato viene stimato con un osservatore di Luenberger.
%
% INPUT:
%   A, B, C     - Matrici del modello dinamico dell'agente
%   ref_type    - Tipo di riferimento: 'constant' | 'ramp' | 'sine'
%   T           - Tempo totale di simulazione (es. 10 secondi)
%   dt          - Passo di integrazione (es. 0.01)
%
% OUTPUT:
%   x0_hist     - Stati reali del leader nel tempo [2 x N]
%   u0_hist     - Comandi di controllo applicati [1 x N]
%   t           - Vettore temporale [1 x N]

    % === Vettore temporale ===
    t = 0:dt:T;
    N = length(t);
    n = size(A, 1);  % dimensione dello stato

    % === Inizializzazione ===
    x0 = zeros(n, 1);        % stato reale iniziale
    xhat = zeros(n, 1);      % stima iniziale dello stato

    x0_hist = zeros(n, N);   % log dello stato reale
    u0_hist = zeros(1, N);   % log del controllo

    % === Parametri del riferimento ===
    R0 = 0.1;    % ampiezza (posizione finale per costante, pendenza per rampa, ampiezza per seno)
    w0 = 1;      % frequenza per caso sinusoidale

    % === Scelta poli desiderati e condizioni iniziali coerenti ===
    switch lower(ref_type)
        case 'constant'
            % Vuoi che il leader si stabilizzi a posizione R0
            desired_eigs = [0, -5];
            x0 = [0; -R0 * desired_eigs(2)];  % da teorema del valore finale

        case 'ramp'
            % Vuoi che la posizione salga linearmente con pendenza R0
            desired_eigs = [-0.01, -0.001];
            x0 = [0; R0];  % posizione 0, velocità R0

        case 'sine'
            % Vuoi che il leader oscilli con ampiezza R0 e frequenza w0
            desired_eigs = [-0.1 + 1j*w0, -0.1 - 1j*w0];
            x0 = [0; R0];  % oppure [0; R0*w0] per essere ancora più preciso

        otherwise
            error("Tipo riferimento non valido: usare 'constant', 'ramp' o 'sine'");
    end

    % === Calcolo guadagno di controllo K (feedback di stato) ===
    K = place(A, B, desired_eigs);

    % === Calcolo guadagno dell’osservatore Luenberger ===
    L = place(A', C', [-10, -15])';  % poli osservatore arbitrari e stabili

    % === Simulazione con integrazione esplicita (Euler) ===
    for k = 1:N
        % Uscita reale
        y = C * x0;

        % Osservatore: aggiorna stima dello stato
        yhat = C * xhat;
        xhat_dot = A * xhat + B * u0_hist(max(k-1,1)) + L * (y - yhat);
        xhat = xhat + dt * xhat_dot;

        % Calcolo controllo sulla stima dello stato
        u = -K * xhat;

        % Evoluzione reale del sistema
        x0_dot = A * x0 + B * u;
        x0 = x0 + dt * x0_dot;

        % Salva valori
        x0_hist(:, k) = x0;
        u0_hist(k) = u;
    end
end
