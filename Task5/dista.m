function [x_est, a_est] = dista(G, y, Q, lambda, nu, tol)
    % DISTA: Distributed Iterative Soft Thresholding Algorithm (versione con while)
    % Input:
    %   G      : matrice osservazioni (q x n), dove n = n_x + q
    %   y      : vettore delle osservazioni (q x 1)
    %   Q      : matrice dei pesi del grafo di comunicazione (q x q)
    %   lambda : parametro regolarizzazione L1
    %   nu     : step size
    %   tol    : soglia per criterio di arresto (precisione)
    % Output:
    %   x_est  : stima dello stato
    %   a_est  : stima degli attacchi sparsi

    [q, n] = size(G);
    n_x = n - q;         % Dimensione dello stato (escludendo attacchi)
    z = zeros(q, n);     % Ogni riga z(i,:) è la stima locale al nodo i
    z_prev = inf(q, n);  % Inizializza la stima precedente con inf
    k = 0;               % Contatore di iterazioni

    % Ciclo principale: continua finché la variazione tra iterazioni è significativa
    while true
        k = k + 1;  % Incrementa contatore
        z_old = z;  % Salva la stima corrente per il confronto

        % Per ogni nodo i, aggiorna la sua stima z(i,:)
        for i = 1:q
            % Calcola la media pesata delle stime dei nodi vicini
            weighted_sum = Q(i,:) * z_old;  % prodotto riga-vettore → (1 x n)

            % Calcola il gradiente locale per il nodo i
            grad_i = G(i,:)' * (y(i) - G(i,:) * z_old(i,:)');  % (n x 1)

            % Applica l'aggiornamento tipo ISTA con soft-thresholding
            temp = weighted_sum + nu * grad_i';  % somma vettoriale (1 x n)
            z(i,:) = soft_threshold(temp', nu * lambda)';  % soft-threshold
        end

        % Calcola la variazione tra le iterazioni successive
        delta = norm(z - z_old, 'fro')^2;

        % Criterio di arresto: se variazione piccola, esci dal ciclo
        if delta < tol
            disp("uscita per Stop Criteria");
            disp(k);  % stampa numero di iterazioni eseguite
            break;
        end
    end

    % Calcola la media finale tra le stime di tutti i nodi
    z_avg = mean(z, 1)';  % (n x 1)

    % Estrai la stima dello stato x e degli attacchi a
    x_est = z_avg(1:n_x);
    a_est = z_avg(n_x+1:end);

    % Filtro finale: elimina gli attacchi stimati troppo piccoli
    a_est(abs(a_est) < 1) = 0;  % soglia fissa (può essere adattata)
end

% Funzione di soft-thresholding vettoriale
function z = soft_threshold(v, thresh)
    % Applica soft-thresholding: z_i = sign(v_i) * max(|v_i| - thresh, 0)
    z = sign(v) .* max(abs(v) - thresh, 0);
end
