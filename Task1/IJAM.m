function [x, a, state_errors] = IJAM(C, y, lambda, nu, max_iter, tol, x_true)
    [q, n] = size(C);
    x = zeros(n,1);
    a = zeros(q,1);
    
    % Uso della pseudo-inversa regolarizzata
    C_pinv = pinv(C, 1e-3);
    state_errors = zeros(max_iter, 1);
    
    for k = 1:max_iter
        x_old = x;
        
        % Aggiornamento di x
        x = C_pinv * (y - a);
        
        % Aggiornamento di a con soft-thresholding
        a = sign(a - nu * (C*x + a - y)) .* max(abs(a - nu * (C*x + a - y)) - lambda * nu, 0);
        
        % Controllo stabilità numerica
        if any(isnan(x)) || any(isinf(x))
            warning('Divergenza in IJAM: x è NaN o inf');
            break;
        end
        if any(isnan(a)) || any(isinf(a))
            warning('Divergenza in IJAM: a è NaN o inf');
            break;
        end
        
        % Calcolo errore
        state_errors(k) = norm(x - x_true) / (norm(x_true) + 1e-8);
        
        % Controllo di convergenza
        if norm(x - x_old, 2) < tol && k > 100
            disp("Convergenza IJAM");
            break;
        end
    end
end
