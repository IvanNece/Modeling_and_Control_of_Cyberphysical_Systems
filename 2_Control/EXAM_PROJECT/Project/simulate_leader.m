function [x0_hist, u0_hist, t] = simulate_leader(A, B, C, ref_type, T, dt)
% SIMULATE_LEADER - Simula il comportamento del leader (S0)
% usando controllo a feedback di stato + osservatore Luenberger.
%
% Il leader insegue un riferimento dato (costante, rampa o seno).
%
% INPUT:
%   A, B, C     - Matrici del modello del sistema
%   ref_type    - Tipo di riferimento: 'constant' | 'ramp' | 'sine'
%   T           - Durata della simulazione (es. 10 secondi)
%   dt          - Passo di integrazione (es. 0.01)
%
% OUTPUT:
%   x0_hist     - Storia dello stato reale del leader nel tempo [2 x N]
%   u0_hist     - Storia del comando di controllo nel tempo [1 x N]
%   t           - Vettore temporale [1 x N]

    % === Parametri iniziali ===
    t = 0:dt:T;         % vettore temporale
    N = length(t);      % numero di passi
    n = size(A, 1);     % dimensione dello stato

    x0 = zeros(n, 1);         % stato reale del leader
    xhat = zeros(n, 1);       % stato stimato (osservatore)

    x0_hist = zeros(n, N);    % log degli stati nel tempo
    u0_hist = zeros(1, N);    % log del controllo nel tempo

    % === Selezione dei poli in base al tipo di riferimento ===
    switch lower(ref_type)
        case 'constant'
            des_poles = [0, -5];          % polo in 0 per eliminare errore costante
            v0 = 0.5;                     % velocità iniziale → raggiunge quota fissa

        case 'ramp'
            des_poles = [-0.01, -0.001];  % poli piccoli negativi ≈ comportamento ramp
            v0 = 0.1;                     % velocità iniziale → pendenza della rampa

        case 'sine'
            omega = 1;                    % frequenza della sinusoide
            des_poles = [-0.1 + 1j*omega, -0.1 - 1j*omega];  % poli complessi smorzati
            v0 = 0.1;                     % ampiezza iniziale

        otherwise
            error('Tipo di riferimento non valido. Usa: constant | ramp | sine');
    end

    % === Controllore K tramite posizionamento poli ===
    K = place(A, B, des_poles);

    % === Osservatore Luenberger (posizionamento poli arbitrari stabili) ===
    L = place(A', C', [-10, -15])';

    % === Condizione iniziale coerente ===
    x0 = [0; v0]; % posizione 0, velocità iniziale impostata sopra

    % === Simulazione tempo-discreto (Euler esplicito) ===
    for k = 1:N
        % Uscita reale del sistema
        y = C * x0;

        % Uscita stimata dall'osservatore
        yhat = C * xhat;

        % Osservatore Luenberger: stima stato
        xhat_dot = A * xhat + B * u0_hist(max(k-1,1)) + L * (y - yhat);
        xhat = xhat + dt * xhat_dot;

        % Calcolo controllo con stato stimato
        u = -K * xhat;

        % Aggiorna stato reale del leader
        x0_dot = A * x0 + B * u;
        x0 = x0 + dt * x0_dot;

        % Salvataggio dati
        x0_hist(:, k) = x0;
        u0_hist(k) = u;
    end
end
