function [x, a, state_errors, attack_errors] = IJAM(C, y, lambda, nu, max_iter, tol, x_true, a_true)
    [q, n] = size(C);
    x = zeros(n,1);
    a = zeros(q,1);
    C_pinv = pinv(C, 1e-3);
    state_errors = zeros(max_iter, 1);
    attack_errors = zeros(max_iter, 1);

    for k = 1:max_iter
        x_old = x;
        x = C_pinv * (y - a);
        a = sign(a - nu * (C*x_old + a - y)) .* max(abs(a - nu * (C*x_old + a - y)) - lambda * nu, 0);

        if any(isnan(x)) || any(isinf(x)) || any(isnan(a)) || any(isinf(a))
            warning('Divergenza in IJAM');
            break;
        end

        state_errors(k) = norm(x - x_true) / (norm(x_true) + 1e-8);
        attack_errors(k) = sum(abs((a ~= 0) - (a_true ~= 0))) / q;

        % if norm(x - x_old, 2) < tol && k > 100
        %     %disp("Convergenza IJAM");
        %     break;
        % end
    end
end
