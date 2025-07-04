function [K, c, F, L1, Aa_obv, Ba_obv, Ca_obv, Da_obv] = control(A, B, C, K0, L, G, p)
    % CONTROL gestisce la progettazione dei guadagni di retroazione, osservatori e altri parametri di controllo

    %% Progettazione di K
    % Parametri di ponderazione (i parametri sono definiti in params.m)
    Q = p.Q;  % Matrice di ponderazione per lo stato (definita in params.m)
    R = p.R;  % Matrizzazione di ponderazione (ingresso) come numero scalare

    % Risoluzione dell'equazione di Riccati per sistemi continui (LQR)
    P = care((A - B*K0), B, Q, R);  % Risolve l'equazione di Riccati algebrica

    % Guadagno del controllore
    K = inv(R) * B' * P;  % Guadagno del controllore

    %% Progettazione di c (Guadagno di accoppiamento)
    lambda = eig(L + G);  % Autovalori di L + G
    real_parts = real(lambda);  
    min_real = min(real_parts(real_parts > 0));  % Trova il minimo autovalore positivo
    c_minimum = 1 / (2 * min_real);  % Valore minimo per c
    c = c_minimum;

    %% Progettazione di F (Guadagno per osservatore)
    Q = 10 * eye(2);  % Matrizzazione per l'osservatore
    R = 1;  % Matrizzazione per l'osservatore

    P2 = care((A - B * K0)', C' * inv(R) * C, Q);  % Soluzione dell'equazione di Riccati per F
    F = P2 * C' * inv(R);  % Guadagno dell'osservatore

    %% OBSV - Leader (osservatore per il leader)
    L1 = place(A', C', [-2 -1])';  % Guadagno per l'osservatore del leader
    A0_obv = A - L1 * C;  % Dinamica del leader osservata
    B0_obv = [L1 B];      % Matrimonio tra il guadagno e l'ingresso
    C0_obv = eye(2);      % Uscita per il leader osservato
    D0_obv = zeros(2);    % Componente di uscita

    %% OBSV - Agenti (osservatore per i follower)
    F1 = place((A - B * K0)', C', [-1 -2])';  % Guadagno per l'osservatore dei follower
    Aa_obv = (A - B * K0) - c * F1 * C;  % Dinamica osservata dei follower
    Ba_obv = [B c * F1];  % Ingresso per gli agenti
    Ca_obv = eye(2);      % Uscita per gli agenti osservati
    Da_obv = zeros(2);    % Componente di uscita
end
