function F = design_F(A, C, Q, R)
% DESIGN_F - Calcola il guadagno dell'osservatore (cooperativo o locale)
%
% Input:
%   A, C - Matrici del sistema
%   Q, R - Matrici di peso per l'osservatore (positive definite)
%
% Output:
%   F - Guadagno dell'osservatore

    % Risolvo l'Algebraic Riccati Equation per l'osservatore
    P = care(A', C', Q, R);

    % Calcolo il guadagno F
    F = P * C' / R;
end
