function [A, B, C, D] = plant_definition()
    % Modello lineare del sistema a levitazione magnetica
    A = [0 1;
         880.87 0];

    B = [0;
        -9.9453];

    C = [708.27 0];

    D = 0;
end
