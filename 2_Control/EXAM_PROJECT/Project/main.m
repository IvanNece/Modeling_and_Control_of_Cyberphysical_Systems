close all;
clear all;
clc;

addpath("control\")
addpath("topologies\")
addpath("utils\")

%% Carica i parametri del progetto
p = params();  % Carica i parametri dal file params.m

%% Configurazione rumore

leader_noise_ts = p.time_step;      % Passo temporale per i blocchi discreti (come il rumore)
noise_sensitivity = 0.1; 
% Esporta le variabili nel workspace di Simulink
assignin('base', 'leader_noise_ts', leader_noise_ts);
assignin('base', 'noise_sensitivity', noise_sensitivity);

% Sensibilità individuale del rumore per ogni agente (dimensione N)
agent_noise_sensitivity_vector = [0.1 0 0.1 0 0 0.2];  
% Esporta ogni valore come 'agent_noise_sensitivity_i'
for i = 1:6
    assignin('base', sprintf('agent_noise_sensitivity_%d', i), agent_noise_sensitivity_vector(i));
end



%% Assegnazione id agenti
num_agents = 6;                  % Numero di agenti nel sistema

for i = 0:num_agents
    assignin('base', sprintf('agent_%d', i), i);
end

%% Scegli la Topologia (usiamo la topologia come stringa, non come numero)
topology = p.topology_type;  % Usa la topologia definita in params.m (stringa: 'line', 'ring', 'mesh', 'full')

% Genera la topologia con il file che hai creato
topos = generate_topology();
switch topology
    case 'line'
        topology_data = topos.line;    % Topologia lineare
    case 'ring'
        topology_data = topos.ring;    % Topologia ad anello
    case 'mesh'
        topology_data = topos.mesh;    % Topologia mesh
    case 'full'
        topology_data = topos.full;    % Topologia completamente connessa
    otherwise
        error('Topologia non valida! Scegli tra: ''line'', ''ring'', ''mesh'', ''full''.');
end

L = topology_data{1}; % Matrice del Laplaciano
G = topology_data{2}; % Matrice di pinning (Leader è S1)
adj = topology_data{3}; % Matrice di adiacenza

%% Dinamica del sistema (Maglev)
A = [0, 1; 880.87, 0];  % Matrice di stato
B = [0; -9.9453];       % Matrice di ingresso
C = [708.27 0];         % Matrice di uscita
D = 0;                  % Matrice di uscita per il controllo (spesso zero)

%% Controllo del sistema e progettazione dei guadagni
scelta = p.scelta_riferimento; % Scegli il riferimento per il leader ('step', 'ramp', 'sin')

switch lower(scelta)
    case 'step'
        eigs = [0, -1]; 
        K0 = place(A, B, eigs);  % Progettazione di K0 per riferimento step
    case 'ramp'
        eigs = [0, 0];
        K0 = acker(A, B, eigs);  % Progettazione di K0 per riferimento ramp
    case 'sin'
        eigs = [+j, -j];
        K0 = place(A, B, eigs);  % Progettazione di K0 per riferimento sinusoidale
    otherwise
        error('Riferimento non valido! Scegli tra: step, ramp, sin.');
end

% Matrici del leader (per Simulink o per la simulazione)
A0 = A;
B0 = B;
C0 = [C; eye(2)];
D0 = zeros(3, 1);

%% Calcolo dei guadagni e degli osservatori
[K, c, F, L1, A0_obv, B0_obv, C0_obv, D0_obv, Aa_obv, Ba_obv, Ca_obv, Da_obv] = control(A, B, C, K0, L, G, p);


