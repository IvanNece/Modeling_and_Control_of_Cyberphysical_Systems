clc
clear
close all

%% Discretizzazione della funzione di trasferimento
Gp = tf(100, [1 1.2 1]);  % Funzione di trasferimento continua
Ts = 1;  % Tempo di campionamento

Gd = c2d(Gp, Ts, 'zoh');  % Discretizzazione della pianta
disp("Gd(z):")
[znum, zden] = tfdata(Gd, 'v');  % Estrai vettori numeratore e denominatore
disp('Numeratore (znum):'); disp(znum);
disp('Denominatore (zden):'); disp(zden);

%% Generazione dei dati di input-output
H = 10000;  % Numero di campioni
u = randn(H, 1);  % Sequenza casuale di input
w = lsim(Gd, u);  % Risposta del sistema (output)

% Definizione dei parametri n e m delle G discreta, che sono diversi dalla G continua (si nota se la si stampa)
% Parametri del modello (grado dei polinomi)
n = 2;  % ritardi su y
m = 2;  % ritardi su u 
%% DA CHIEDERE AL PROF
%perchè dobbiamo mettere m=2 anche se il grado del num è 1 e a il coeff di
%s^2 pari a 0???? e perchè anche variando H non variano i parametri


%% Costruzione della matrice A e del vettore b
A = zeros(H - n, n + m + 1);  % (H - n) x (n + m + 1) = (H-2) x 5
b = w(n+1:H);                 % Output da tempo n+1 in poi

for k = n+1:H
    A(k - n, :) = [-w(k-1), -w(k-2), u(k), u(k-1), u(k-2)];
end

% Calcolo della stima dei parametri
theta = pinv(A) * b;


%% Confronto tra i parametri stimati e quelli veri di Gd(z)
% Estrazione dei parametri veri da Gd(z)
% Gd(z) = (θ₃·z² + θ₄·z + θ₅) / (z² + θ₁·z + θ₂)
theta_true = [zden(2), zden(3), znum(1), znum(2), znum(3)];


%% Confronto tra parametri stimati e veri
disp('Parametri stimati:');
disp(theta');
disp('Parametri veri:');
disp(theta_true);



