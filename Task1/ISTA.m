function [x, a, state_errors] = ISTA(C, y, lambda, nu, max_iter, tol, x_true)
    [q, n] = size(C);
    x = zeros(n,1);
    a = zeros(q,1);
    state_errors = zeros(max_iter, 1);
    
    for k = 1:max_iter
        x_old = x;
        
        % Aggiornamento di x con un passo di gradiente
        x = x - nu * C' * (C*x + a - y);
        
        % Soft-thresholding per aggiornare a
        a = sign(a - nu * (C*x + a - y)) .* max(abs(a - nu * (C*x + a - y)) - lambda * nu, 0);
        
        % Controllo stabilità numerica
        if any(isnan(x)) || any(isinf(x))
            warning('Divergenza in ISTA: x è NaN o inf');
            break;
        end
        if any(isnan(a)) || any(isinf(a))
            warning('Divergenza in ISTA: a è NaN o inf');
            break;
        end
        
        % Calcolo errore
        state_errors(k) = norm(x - x_true) / (norm(x_true) + 1e-8);
        
        % Controllo di convergenza
        if norm(x - x_old, 2) < tol && k > 100
            disp("Convergenza ISTA");
            break;
        end
    end
end
