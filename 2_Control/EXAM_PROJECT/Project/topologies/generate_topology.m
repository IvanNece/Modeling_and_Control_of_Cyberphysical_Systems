function topos = generate_topology()
% GENERATE_TOPOLOGY genera 4 topologie standard tra follower:
% - 'line': S1 ← S2 ← S3 ← S4 ← S5 ← S6
% - 'ring': come 'line' ma con S6 → S1 (topologia circolare)
% - 'mesh': connessi in modo sparso ma non completamente
% - 'full': tutti connessi a tutti (senza self-loop)
%
% Output:
%   topos - struttura con 4 campi: .line, .ring, .mesh, .full
%           ognuno contiene una cella {L, G, adj}:
%           - L: matrice del Laplaciano
%           - G: matrice di pinning (S1 è il leader)
%           - adj: matrice di adiacenza

    % Definisco i tipi di topologie che voglio generare
    tipi = {'line', 'ring', 'mesh', 'full'};
    N = 6; % Numero di follower
    topos = struct(); % Inizializzo la struttura di output

    for k = 1:length(tipi)
        type = tipi{k}; % Tipo di topologia
        adj = zeros(N);  % Inizializzo la matrice di adiacenza a zero

        % --- Costruzione della matrice di adiacenza ---
        switch type
            case 'line'
                % Line topology: S1 ← S2 ← S3 ← ... ← S6
                for i = 1:N-1
                    adj(i+1, i) = 1; % Ogni nodo è connesso al precedente
                end

            case 'ring'
                % Ring topology: S1 ↔ S2 ↔ ... ↔ S6 ↔ S1 (simmetrica)
                for i = 1:N-1
                    adj(i, i+1) = 1;   % Connessione i → i+1
                    adj(i+1, i) = 1;   % Connessione i+1 → i (simmetrica)
                end
                % Chiudo l'anello: S6 ↔ S1
                adj(N, 1) = 1;         % Connessione S6 → S1
                adj(1, N) = 1;         % Connessione S1 → S6 (simmetrica)

            case 'mesh'
                % Mesh topology: Pattern fisso e semplice
                adj = zeros(N);
                
                % Ring base
                for i = 1:N-1
                    adj(i, i+1) = 1;
                    adj(i+1, i) = 1;
                end
                adj(N, 1) = 1; adj(1, N) = 1;
                
                % Connessioni diagonali fisse
                adj(1, 3) = 1; adj(3, 1) = 1;  % 1-3
                adj(2, 4) = 1; adj(4, 2) = 1;  % 2-4
                adj(3, 5) = 1; adj(5, 3) = 1;  % 3-5
                adj(4, 6) = 1; adj(6, 4) = 1;  % 4-6
                adj(1, 4) = 1; adj(4, 1) = 1;  % 1-4
                adj(2, 5) = 1; adj(5, 2) = 1;  % 2-5

            case 'full'
                % Full topology: Tutti connessi a tutti (senza self-loop)
                adj = ones(N) - eye(N); % Ogni nodo è connesso a tutti tranne che a se stesso
        end

        % --- Calcolo del Laplaciano: L = D - adj ---
        D = diag(sum(adj, 2)); % La matrice diagonale dei gradi (somme delle righe)
        L = D - adj; % Laplaciano: D - adj

        % --- Costruzione della matrice di Pinning: Leader è S1 ---
        G = zeros(N); % Inizializzo la matrice di pinning
        G(1, 1) = 1; % S1 è il leader, quindi G(1, 1) = 1

        % --- Salvataggio della topologia nella struttura topos ---
        topos.(type) = {L, G, adj}; % Aggiungo L, G e adj per ogni tipo di topologia
    end
end
