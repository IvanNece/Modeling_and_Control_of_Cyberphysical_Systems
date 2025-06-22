clear; clc; close all;

%% === RING TOPOLOGY ===

load("Q_ring.mat");
G_ring = digraph(Q);

% Ordine personalizzato dei nodi (dato da te)
custom_order = [1 6 9 14 2 16 12 17 10 4 20 11 13 15 7 5 8 18 19 3];

% Posizioni circolari secondo l'ordine
theta = linspace(0, 2*pi, numel(custom_order)+1);
theta(end) = [];
x = cos(theta);
y = sin(theta);

% Vettori posizione vuoti
XData = zeros(1, numel(custom_order));
YData = zeros(1, numel(custom_order));

% Assegna posizioni secondo ordine custom
for i = 1:length(custom_order)
    XData(custom_order(i)) = x(i);
    YData(custom_order(i)) = y(i);
end

% Plot Ring con disposizione personalizzata
figure;
plot(G_ring, ...
    'XData', XData, ...
    'YData', YData, ...
    'NodeColor', 'r', ...
    'EdgeColor', 'k', ...
    'ArrowSize', 9, ...
    'LineWidth', 1.2, ...
    'MarkerSize', 6, ...
    'NodeLabel', 1:20);
title('Ring Topology', 'FontSize', 14, 'FontWeight', 'bold');
axis off;
saveas(gcf,"ring.png");


%% === STAR TOPOLOGY ===

load("Q_star.mat");
G_star = digraph(Q);

numNodes = size(Q,1);
theta = linspace(0, 2*pi, numNodes);
x = cos(theta);
y = sin(theta);
x(1) = 0; y(1) = 0;  % Nodo centrale al centro

figure;
plot(G_star, ...
    'XData', x, ...
    'YData', y, ...
    'NodeColor', 'r', ...
    'EdgeColor', 'k', ...
    'ArrowSize', 9, ...
    'LineWidth', 1.2, ...
    'MarkerSize', 6);
title('Star Topology', 'FontSize', 14, 'FontWeight', 'bold');
axis off;
saveas(gcf, "star.png");
