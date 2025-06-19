function [x, a, state_errors, attack_errors] = ISTA(C, y, lambda, nu, max_iter, tol, x_true, a_true)
    [q, n] = size(C);
    x = zeros(n,1);
    a = zeros(q,1);
    state_errors = zeros(max_iter, 1);
    attack_errors = zeros(max_iter, 1);

    for k = 1:max_iter
        x_old = x;
        x = x - nu * C' * (C*x + a - y);
        a = sign(a - nu * (C*x_old + a - y)) .* max(abs(a - nu * (C*x_old + a - y)) - lambda * nu, 0);

        if any(isnan(x)) || any(isinf(x)) || any(isnan(a)) || any(isinf(a))
            warning('Divergenza in ISTA');
            break;
        end

        state_errors(k) = norm(x - x_true) / (norm(x_true) + 1e-8);

        % Support attack error (somma delle differenze tra supporti, senza normalizzazione)
        support_true = double(a_true ~= 0);
        support_est  = double(a ~= 0);
        attack_errors(k) = sum(abs(support_true - support_est));
    end
end