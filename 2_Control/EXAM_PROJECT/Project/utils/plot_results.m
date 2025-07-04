function plot_results(time, error_data)
% PLOT_RESULTS traccia i risultati della simulazione
% Input:
%   time - vettore dei tempi
%   error_data - errore di stato tra il leader e i follower

    % Crea il grafico
    figure;
    plot(time, error_data, 'LineWidth', 2);
    xlabel('Tempo (s)', 'FontSize', 12);
    ylabel('Errore di stato', 'FontSize', 12);
    title('Errore di Stato nel Tempo', 'FontSize', 14);
    grid on;
end
