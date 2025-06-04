function topos = generate_topology()
% GENERATE_TOPOLOGY genera 3 topologie standard tra follower:
% - 'line': S1 ← S2 ← S3 ← S4 ← S5 ← S6
% - 'ring': come 'line' ma con S6 → S1
% - 'full': tutti connessi a tutti (no self-loop)
%
% Output:
%   topos - struttura con 3 campi: .line, .ring, .full
%           ognuno contiene una cella {L, G, adj}

    tipi = {'line', 'ring', 'full'};
    N = 6; % numero di follower
    topos = struct(); % inizializzazione della struct

    for k = 1:length(tipi)
        type = tipi{k};
        adj = zeros(N);  % matrice di adiacenza

        % --- Costruzione della matrice di adiacenza ---
        switch type
            case 'line'
                % Line topology:
                % S1 ← S2 ← S3 ← S4 ← S5 ← S6
                for i = 1:N-1
                    adj(i+1, i) = 1;
                end

            case 'ring'
                % Ring topology:
                % S1 ← S2 ← S3 ← S4 ← S5 ← S6 ← S1
                for i = 1:N-1
                    adj(i+1, i) = 1;
                end
                adj(1, N) = 1;

            case 'full'
                % Full topology:
                % Tutti connessi a tutti (no self-loop)
                adj = ones(N) - eye(N);
        end

        % --- Laplaciano L = D - adj ---
        D = diag(sum(adj, 2));
        L = D - adj;

        % --- Pinning matrix: leader → S1 ---
        G = zeros(N);
        G(1,1) = 1;

        % --- Salvataggio della topologia ---
        topos.(type) = {L, G, adj};
    end
end
