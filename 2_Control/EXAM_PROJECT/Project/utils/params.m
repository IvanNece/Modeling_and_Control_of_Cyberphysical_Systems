function p = params()
% PARAMS restituisce i parametri generali per il progetto

    % Numero di follower
    p.N = 6;  % numero di follower (6 in totale)
    
    % Parametri per il controllore
    p.c = 0.5;  % Guadagno di accoppiamento (c)
    
    % Parametri di Lyapunov per l'osservatore
    p.Q = eye(2);  % Matrizzazione di ponderazione (stato)
    p.R = 1;     % Matrizzazione di ponderazione (ingresso) come un numero scalare, come nel codice del tuo amico
    
    % Matrice di pinning (S1 è il leader)
    p.G = zeros(p.N);
    p.G(1, 1) = 1;  % Leader è S1
    
    % Parametri di simulazione
    p.sim_time = 10;  % Durata della simulazione (in secondi)
    p.time_step = 0.1;  % Passo temporale (in secondi)
    
    % Parametri per la topologia
    p.topology_type = 'line';  % Scegliere la topologia (es. 'line', 'ring', 'mesh', 'full')
    
    % Tipo di riferimento per il leader
    p.scelta_riferimento = 'step';  % Scegli il riferimento per il leader ('step', 'ramp', 'sin')
end
