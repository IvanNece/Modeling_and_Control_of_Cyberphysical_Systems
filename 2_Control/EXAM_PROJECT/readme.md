# Distributed Control of Multi-Agent Magnetic Levitation Systems

This repository implements a modular and extensible MATLAB & Simulink framework for **distributed control** of a network of magnetic levitation (Maglev) systems (Part II).

The project focuses on:

- Distributed cooperative tracking of a reference leader  
- Design and comparison of **Local** vs **Neighborhood** observers  
- Simulation under different **network topologies**  
- Analysis of robustness with **output measurement noise**  
- Evaluation of system performance 

---

## 📁 Project Structure

```text
Project/
│
├── main.m                      
# Main script: system configuration and controller setup
│
├── /control/                  
│   └── control.m              
# LQR gain computation, observer design (F, L1), coupling gain check
│
├── /topologies/               
│   └── generate_topology.m    
# Adjacency, Laplacian and pinning matrix generation 
for: line, ring, mesh, full topologies
│
├── /utils/                    
│   └── params.m               
# General parameters: N, c, Q, R, topology, noise, simulation time
│
├── /simulations/              
│   ├── Local.slx              
# Simulink model using local observers (output-based)
│   └── Neighborhood.slx       
# Simulink model using cooperative observers (distributed consensus)
│
├── /analyses/                 
# Numerical results and analysis
│   ├── 1_topologies/          
# Comparison across different topologies
│   ├── 2_references/          
# Effect of reference signal (step, ramp, sinusoid)
│   ├── 3_tuning_parameters/   
# Sensitivity to Q, R and coupling gain c
│   ├── 4_local_vs_neighborhood/ 
# Performance comparison of observer types
│   └── 5_noise/               
# Effects of noise on topology and node position
```

---

## 🧪 How to Run

1. Open `params.m` and configure:
   - `c` → coupling gain
   - `Q`, `R` → LQR tuning matrices
   - `topology_type` → `'line' | 'ring' | 'mesh' | 'full'`
   - `scelta_riferimento` → `'step' | 'ramp' | 'sin'`
   - Noise: `noise_sensitivity`, `agent_noise_sensitivity_vector`

2. Run `main.m` to load parameters and generate the network.

3. Open one of the Simulink models:
   - `Local.slx` → decentralized observer design
   - `Neighborhood.slx` → distributed estimation with neighbor cooperation

4. Simulate and analyze the system behavior.
5. Check the `/analyses/` folder for numerical results and performance plots.

---

## ⚙️ System Description

### Simulink Models
- `Local.slx`: decentralized estimation using Luenberger observers
- `Neighborhood.slx`: distributed cooperative estimation with consensus dynamics

### Controller & Observer Design
- State-feedback `K` from LQR (`care`)
- Observer matrices `F` and `L1` via pole placement or dual LQR
- Interaction topology defined by Laplacian and pinning matrices

### Supported Topologies
- **Line**: directional chain (leader at one end)
- **Ring**: closed-loop symmetric network
- **Mesh**: sparsely connected intermediate graph
- **Full**: fully connected communication

Topology is selected via: `params.m → p.topology_type`.

### Noise Injection
- **Leader noise** on leader output: `p.noise_sensitivity`
- **Agent noise** per agent: `p.agent_noise_sensitivity_vector` (6-element vector) 

---

## 📊 Analysis Modules

All analysis results are saved under `/analyses/` and organized into the following categories:

| Folder | Description |
|--------|-------------|
| `1_topologies/` | Performance comparison across Line, Ring, Mesh, Full |
| `2_references/` | Evaluation with different reference types (step, ramp, sinusoid) |
| `3_tuning_parameters/` | Effect of varying Q, R and coupling gain \( c \) |
| `4_local_vs_neighborhood/` | Comparison between local and distributed observer structures |
| `5_noise/` | Robustness against noise on specific agents and topological impact |

Folders includes:
- Position and velocity trajectories
- Tracking error over time
- Control input plots per agent
- Energy consumption
- Observations and theoretical interpretation (in LaTeX)

---
