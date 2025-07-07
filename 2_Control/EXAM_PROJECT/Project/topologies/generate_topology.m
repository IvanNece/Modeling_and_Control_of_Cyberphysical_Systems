function topos = generate_topology()
% GENERATE_TOPOLOGY generates 4 standard follower topologies:
% - 'line': S1 ← S2 ← S3 ← S4 ← S5 ← S6
% - 'ring': like 'line' but with S6 → S1 (circular topology)
% - 'mesh': sparse connections, not fully connected
% - 'full': fully connected network (no self-loops)
%
% Output:
%   topos - structure with 4 fields: .line, .ring, .mesh, .full
%           each containing a cell array {L, G, adj}:
%           - L: Laplacian matrix
%           - G: pinning matrix (S1 is the leader)
%           - adj: adjacency matrix

    types = {'line', 'ring', 'mesh', 'full'};  % List of topology types
    N = 6;  % Number of follower agents
    topos = struct();  % Initialize output structure

    for k = 1:length(types)
        type = types{k};          % Current topology type
        adj = zeros(N);           % Initialize adjacency matrix

        % --- Build adjacency matrix ---
        switch type
            case 'line'
                % Line topology: S1 ← S2 ← S3 ← ... ← S6
                for i = 1:N-1
                    adj(i+1, i) = 1;  % Each agent connects to its predecessor
                end

            case 'ring'
                % Ring topology: S1 ↔ S2 ↔ ... ↔ S6 ↔ S1
                for i = 1:N-1
                    adj(i, i+1) = 1;   % Connection i → i+1
                    adj(i+1, i) = 1;   % Connection i+1 → i
                end
                % Close the ring
                adj(N, 1) = 1;         
                adj(1, N) = 1;

            case 'mesh'
                % Sparse mesh topology with additional diagonal connections
                adj = zeros(N);
                
                % Ring base
                for i = 1:N-1
                    adj(i, i+1) = 1;
                    adj(i+1, i) = 1;
                end
                adj(N, 1) = 1; adj(1, N) = 1;
                
                % Additional cross-links
                adj(1, 3) = 1; adj(3, 1) = 1;
                adj(2, 4) = 1; adj(4, 2) = 1;
                adj(3, 5) = 1; adj(5, 3) = 1;
                adj(4, 6) = 1; adj(6, 4) = 1;
                adj(1, 4) = 1; adj(4, 1) = 1;
                adj(2, 5) = 1; adj(5, 2) = 1;

            case 'full'
                % Fully connected topology (no self-loops)
                adj = ones(N) - eye(N);  % All-to-all connectivity
        end

        % --- Compute Laplacian matrix: L = D - adj ---
        D = diag(sum(adj, 2));  % Degree matrix (row sums)
        L = D - adj;            % Laplacian matrix

        % --- Define pinning matrix: S1 is the leader ---
        G = zeros(N);       
        G(1, 1) = 1;  % Only agent 1 (S1) is pinned to the leader

        % --- Store topology matrices in output structure ---
        topos.(type) = {L, G, adj};  % Save L, G, adj for this topology
    end
end
