% Lab 2 - Modeling and Control of CPS
% MINIMIZATION of theta_1 using SparsePOP + SeDuMi
% Style inspired by Ex_POP_basic.m

clear all
close all
load('exp_data.mat') % loads u and ytilde

% -------------------------------
% STEP 1 — Define dimensions
% -------------------------------
nTheta = 5;        % Number of parameters theta_i
nNoise = 48;       % eta(k) from k = 3 to 50
nVar = nTheta + nNoise;  % Total number of optimization variables

% -------------------------------
% STEP 2 — Objective: min theta1
% -------------------------------
objPoly.typeCone = 1;
objPoly.dimVar = nVar;
objPoly.degree = 1;
objPoly.noTerms = 1;
objPoly.supports = [1, zeros(1, nVar - 1)];
objPoly.coef = 1;

% -------------------------------
% STEP 3 — Constraints from data
% -------------------------------
ineqPolySys = {};
for k = 3:50
    y1 = y_tilde(k-1);
    y2 = y_tilde(k-2);
    u0 = u(k);
    u1 = u(k-1);
    u2 = u(k-2);
    yk = y_tilde(k);
    
    support = [];
    coef = [];

    % -theta1 * y(k-1)
    support = [support; [1 0 0 0 0 zeros(1, nNoise)]];
    coef = [coef; -y1];

    % -theta2 * y(k-2)
    support = [support; [0 1 0 0 0 zeros(1, nNoise)]];
    coef = [coef; -y2];

    % +theta3 * u(k-2)
    support = [support; [0 0 1 0 0 zeros(1, nNoise)]];
    coef = [coef; u2];

    % +theta4 * u(k-1)
    support = [support; [0 0 0 1 0 zeros(1, nNoise)]];
    coef = [coef; u1];

    % +theta5 * u(k)
    support = [support; [0 0 0 0 1 zeros(1, nNoise)]];
    coef = [coef; u0];

    % +eta(k) → variable index: nTheta + (k-2)
    eta_idx = nTheta + (k - 2);
    eta_support = zeros(1, nVar);
    eta_support(eta_idx) = 1;
    support = [support; eta_support];
    coef = [coef; 1];

    % -ytilde(k) (constant term)
    support = [support; zeros(1, nVar)];
    coef = [coef; -yk];

    % Save constraint (equality)
    ineqPolySys{end+1}.typeCone = -1;
    ineqPolySys{end}.dimVar = nVar;
    ineqPolySys{end}.degree = 1;
    ineqPolySys{end}.noTerms = size(support, 1);
    ineqPolySys{end}.supports = support;
    ineqPolySys{end}.coef = coef;
end

% -------------------------------
% STEP 4 — Variable bounds
% -------------------------------
lbd = [-1000 * ones(1, nTheta), -5 * ones(1, nNoise)];
ubd = [ 1000 * ones(1, nTheta),  5 * ones(1, nNoise)];

% -------------------------------
% STEP 5 — SparsePOP parameters
% -------------------------------
param.relaxOrder = 3;
param.POPsolver = 'active-set';

% -------------------------------
% STEP 6 — Run SparsePOP
% -------------------------------
[param,SDPobjValue,POP,elapsedTime,SDPsolverInfo,SDPinfo] = ...
    sparsePOP(objPoly, ineqPolySys, lbd, ubd, param);

% -------------------------------
% STEP 7 — Results
% -------------------------------
fprintf('\n--- RESULTS ---\n');
fprintf('Relaxed optimum (SDPobjValue): %.6f\n', SDPobjValue);
fprintf('Refined optimum (POP.objValueL): %.6f\n', POP.objValueL);
%fprintf('Estimated theta_1 (POP.xVectL(1)): %.6f\n', POP.xVectL(1));
