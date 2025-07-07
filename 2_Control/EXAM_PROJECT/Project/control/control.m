function [K, c, F, L1, A0_obv, B0_obv, C0_obv, D0_obv, Aa_obv, Ba_obv, Ca_obv, Da_obv] = control(A, B, C, K0, L, G, p)
% CONTROL computes control gains, observer matrices, and other parameters for the distributed maglev control system.
% It includes separate observer designs for the leader and the followers.

    %% Design of state-feedback gain K (via LQR)
    % Weighting matrices (provided in params.m)
    Q = p.Q;     % State weighting matrix
    R = p.R;     % Input weighting (scalar)

    % Solve Continuous Algebraic Riccati Equation (CARE) for closed-loop performance
    P = care((A - B*K0), B, Q, R);

    % Compute optimal LQR gain
    K = inv(R) * B' * P;

    %% Design of coupling gain c
    lambda = eig(L + G);  % Eigenvalues of the coupling matrix (Laplacian + Pinning)
    real_parts = real(lambda);
    min_real = min(real_parts(real_parts > 0));  % Smallest positive real eigenvalue
    c_minimum = 1 / (2 * min_real);  % Theoretical lower bound on coupling gain

    c = p.c;  % Use the coupling gain specified in params.m

    % Display coupling gain diagnostics (optional)
    fprintf('Theoretical minimum c: %.4f\n', c_minimum);
    fprintf('Selected c: %.4f\n', c);
    if c < c_minimum
        fprintf('WARNING: c < c_minimum. Stability may be compromised.\n');
    end    

    %% Design of observer gain F (for consensus error dynamics)
    Q_obs = 10 * eye(2);  % State weighting for observer design (typically > Q)
    R_obs = 1;            % Measurement weighting

    % Solve CARE for observer design (dual system)
    P2 = care((A - B * K0)', C' * inv(R_obs) * C, Q_obs);
    F = P2 * C' * inv(R_obs);  % Observer gain for consensus estimation

    %% Observer for the leader node
    L1 = place(A', C', [-2 -1])';     % Pole placement for leader observer
    A0_obv = A - L1 * C;              % Observer state matrix (leader)
    B0_obv = [L1 B];                  % Observer input matrix (leader)
    C0_obv = eye(2);                  % Output matrix (identity)
    D0_obv = zeros(2);                % Direct feedthrough (zero)

    %% Observer for follower agents (neighborhood-based)
    F1 = place((A - B * K0)', C', [-1 -2])';  % Pole placement for follower observers
    Aa_obv = (A - B * K0) - c * F1 * C;       % State matrix for observer error dynamics
    Ba_obv = [B c * F1];                      % Input matrix (includes distributed estimation term)
    Ca_obv = eye(2);                          % Output matrix
    Da_obv = zeros(2);                        % Direct feedthrough (zero)
end
