clc
clear
close all

%% Discretizzazione della funzione di trasferimento
Gp = tf(100, [1 1.2 1]);  % Funzione di trasferimento continua
Ts = 1;  % Tempo di campionamento
Gd = c2d(Gp, Ts, 'zoh');  % Discretizzazione della pianta

%% Generazione dei dati di input-output
H = 10000;  % Numero di campioni
u = randn(H, 1);  % Sequenza casuale di input
w = lsim(Gd, u);  % Risposta del sistema (output)

% Definizione dei parametri n e m delle G discreta, che sono diversi dalla
% G continua (si nota se la si stampa)
n = 3;  % Numero di ritardi per l'uscita (y) (elementi denominatore Gd)
m = 2;  % Numero di ritardi per l'ingresso (u) (elementi numeratore Gd)

%% Costruzione della matrice A e del vettore b e stima parametri theta

A = zeros(H - n, m + n);  % Matr A di dimensione (H-n) x (m+n)
b = w(n+1:H);  % Vettore b che è l'uscita a partire dal campione n+1

% Popolamento della matrice A
for k = n+1:H
    A(k - n, :) = [-w(k-1), -w(k-2), -w(k-3), u(k), u(k-1)];  % 3 ritardi su y(k) e 2 su u(k)
end

% Calcolo della stima dei parametri
theta = inv(A' * A) * A' * b;  

%% Confronto tra i parametri stimati e quelli veri di Gd(z)
% Estrazione dei parametri veri da Gd(z)

theta_true = [Gd.Denominator{1}(1), Gd.Denominator{1}(2), ...
              Gd.Denominator{1}(3), Gd.Numerator{1}(3), Gd.Numerator{1}(2)];

% Confronto dei parametri stimati con quelli veri
disp('Parametri stimati:');
disp(theta');
disp('Parametri veri:');
disp(theta_true);



