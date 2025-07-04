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
                % Ring topology: S1 ← S2 ← ... ← S6 ← S1
                for i = 1:N-1
                    adj(i+1, i) = 1; % Ogni nodo è connesso al precedente
                end
                adj(1, N) = 1; % Aggiungo la connessione S6 → S1 (circuito)

            case 'mesh'
                % Mesh topology: Connessioni sparso tra i nodi
                adj = zeros(N);
                for i = 1:N-1
                    adj(i+1, i) = 1; % Ogni nodo è connesso al precedente
                end
                % Aggiungi connessioni casuali per ottenere una topologia a mesh
                for i = 1:N
                    for j = i+2:N
                        if rand > 0.5
                            adj(i, j) = 1;
                            adj(j, i) = 1;
                        end
                    end
                end

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
