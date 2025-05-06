function [x_est, a_est] = dista_star(G, y, Q, lambda, nu, tol)
    % DISTA_STAR: versione centralizzata in topologia a stella
    % Input:
    %   G      : matrice delle osservazioni (q x n), dove n = n_x + q
    %   y      : vettore delle misure (q x 1)
    %   Q      : matrice dei pesi (si assume che la prima riga Q(1,:) sia il nodo centrale)
    %   lambda : parametro di regolarizzazione L1
    %   nu     : step-size
    %   tol    : soglia di tolleranza per il criterio di arresto
    % Output:
    %   x_est  : stima dello stato
    %   a_est  : stima degli attacchi sparsi

    [q, n] = size(G);
    z = zeros(q, n);       % Inizializzazione stime locali z⁽ⁱ⁾(0)
    z_new = z;             % Per memorizzare la nuova iterazione
    delta = inf;           % Inizializza il criterio di arresto
    k = 0;                 % Contatore di iterazioni

    % Loop principale
    while delta > tol
        k = k + 1;

        % Nodo centrale (supposto nodo 0, rappresentato da Q(1,:))
        % Calcola la media pesata delle stime dei nodi periferici
        z0 = Q(1, 2:end) * z;  % prodotto riga-vettore → (1 x n)

        % Ogni nodo aggiorna la propria stima localmente
        for i = 1:q
            Gi = G(i, :);
            yi = y(i);
            grad = Gi' * (yi - Gi * z(i, :)');  % gradiente locale
            z_new(i, :) = soft_threshold(z0 + nu * grad', nu * lambda);
        end

        % Criterio di arresto: norma Frobenius del cambiamento
        delta = norm(z_new - z, 'fro')^2;

        % Aggiorna la variabile per la prossima iterazione
        z = z_new;
    end

    disp("uscita per Stop Criteria");
    disp(k);  % stampa numero di iterazioni eseguite

    % Stima finale come media delle stime locali
    z_final = mean(z, 1)';  % (n x 1)
    n_x = n - q;            % numero di componenti dello stato

    % Estrai lo stato e la stima degli attacchi
    x_est = z_final(1:n_x);
    a_est = z_final(n_x+1:end);

    % Rifinitura finale: annulla gli attacchi stimati piccoli
    a_est(abs(a_est) < 1) = 0;
end

% Funzione di soft-thresholding vettoriale
function z = soft_threshold(v, thresh)
    % Applica soft-thresholding: z_i = sign(v_i) * max(|v_i| - thresh, 0)
    z = sign(v) .* max(abs(v) - thresh, 0);
end
