function [x, a] = ISTAtarget(G, y, lambda, nu, max_iter)
    
    [q, n] = size(G);
    n_x = n - q;  % Numero di celle
    xa = zeros(n, 1);

    for k = 1:max_iter
        % Aggiornamento secondo ISTA
        xa = soft_threshold(xa - nu * (G' * (G * xa - y)), nu * [lambda * ones(n_x,1); lambda * ones(q,1)]);

    end
    % Separazione delle variabili x e a solo alla fine
    x = xa(1:n_x);
    a = xa(n_x+1:end);

end

function z = soft_threshold(v, threshold)
    % Operatore di soft-thresholding per garantire sparsità
    z = sign(v) .* max(abs(v) - threshold, 0);
end