% Example 1: System identification (LTI model, least squares)

close all

clear all

clc

% Plant and equivalent discrete-time "true" model

s = tf('s')

G = 100/(s^2+2*0.6*s*1+1);

Gd = c2d(G,1,'zoh');

H=100000; % number of collected data

% True parameter vector to be identified (parameter of Gd(z))
theta = [-0.7647 0.3012 0 32.24 21.41]' 

u = 2*rand(H,1)-1; %input: uniformly distributed white noise (between -1 and 1)

y = lsim(Gd,u); %true output: simulation of the ideal experiment (no noise) for obtaining the true output


% CASE I: noiseless case

b = y(3:H); 

A = [-y(2:H-1) -y(1:H-2) u(3:H) u(2:H-1) u(1:H-2)];
 
theta_nf = A\b % A\b inv(A'*A)*A'b LS estimate without any uncertainty 

% Noise amplitude
Noise_amp = 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[Nd,Dd] = tfdata(Gd,'v'); %compute numerator and denominator of the system to be identified

% CASE II: equation error structure 

e = Noise_amp*randn(H,1);

for k=3:1:H
    y(k) = -theta(1)*y(k-1)-theta(2)*y(k-2)+theta(3)*u(k)+theta(4)*u(k-1)+theta(5)*u(k-2)+e(k);
end

b = y(3:H);

A = [-y(2:H-1) -y(1:H-2) u(3:H) u(2:H-1) u(1:H-2)];

theta_est_ee = A\b

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eta = Noise_amp*randn(H,1);

ynf = lsim(Gd,u); % true output of the system

ytilde = ynf + eta; % output error (OE) structure (what actually happens in real experiment)

A_oe = [-ytilde(2:H-1) -ytilde(1:H-2) u(3:H) u(2:H-1) u(1:H-2)];

b_oe = ytilde(3:H);

theta_est_oe = A_oe\b_oe % LS estimate with output error

%%%% Computation of estimation error

error_ee = abs(theta_est_ee-theta)./abs(theta)*100 % Estimate error with EE structure

error_oe = abs(theta_est_oe-theta)./abs(theta)*100 % Estimate error with OE structure

[theta theta_est_ee theta_est_oe] % true parameter, estimate with EE, estimate with OE

err_perc = [error_ee error_oe] % comparison of percentage error: EE vs OE






