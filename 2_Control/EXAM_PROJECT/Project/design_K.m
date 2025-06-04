function K = design_K(A, B, Q, R)
% DESIGN_K - Calcola il guadagno di controllo K per il controllore SVFB
%
% Input:
%   A, B - Matrici di stato e controllo del sistema
%   Q, R - Matrici di peso per il criterio LQR (positive definite)
%
% Output:
%   K - Guadagno di feedback ottimale

    % Risolvo l'Algebraic Riccati Equation (ARE)
    P = care(A, B, Q, R);

    % Calcolo il guadagno ottimale
    K = R \ (B' * P);
end
