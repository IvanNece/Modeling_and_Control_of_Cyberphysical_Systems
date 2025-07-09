# Distributed Control of Multi-Agent Magnetic Levitation Systems

This repository implements a modular and extensible MATLAB & Simulink framework for **distributed control** of a network of magnetic levitation (Maglev) systems, based on the course project of *Modeling and Control of Cyber-Physical Systems* (Part II).

The project focuses on:

- Distributed cooperative tracking of a reference leader  
- Design and comparison of **Local** vs **Neighborhood** observers  
- Simulation under different **network topologies**  
- Analysis of robustness with **output measurement noise**  
- Evaluation of system performance 

---

## 📁 Project Structure
Maglev_Project/
│
├── main.m # Main script: system configuration and controller setup
│
├── /control/
│ └── control.m # LQR gain computation, observer design (F, L1), coupling gain check
│
├── /topologies/
│ └── generate_topology.m # Adjacency, Laplacian and pinning matrix generation for:
│ # - line, ring, mesh, full topologies
│
├── /utils/
│ └── params.m # General parameters: N, c, Q, R, topology, noise, simulation time ecc...
│
├── /simulation/
│ ├── Local.slx # Simulink model using local observers (output-based)
│ └── Neighborhood.slx # Simulink model using cooperative observers (distributed consensus)
│
├── /analysis/ # Numerical results, plots, performance comparisons (included separately)


---

## 🧪 How to Run

1. Open `params.m` and configure:
   - `topology_type` → `'line' | 'ring' | 'mesh' | 'full'`
   - `scelta_riferimento` → `'step' | 'ramp' | 'sin'`
   - Noise: `noise_sensitivity`, `agent_noise_sensitivity_vector`

2. Run `main.m` to load parameters and generate the network.

3. Open one of the Simulink models:
   - `Local.slx` → decentralized observer design
   - `Neighborhood.slx` → distributed estimation with neighbor cooperation

4. Simulate and analyze the system behavior.
5. Check the `/analysis/` folder for numerical results and performance plots.

---

## ⚙️ How It Works

### Simulink Models
- `Local.slx`: each agent uses a **local observer** based on its output  
- `Neighborhood.slx`: each agent uses a **cooperative observer** using neighbors’ outputs  

### Observer Design
- LQR controller `K` computed using `care`  
- Observer gains `F` and `L1` computed using `place` or dual LQR  
- Agents implement a distributed estimator using topology-defined interactions  

### Topologies
Four types of topologies define neighbor relations:
- `'line'`: directed chain  
- `'ring'`: circular symmetric  
- `'mesh'`: sparse connections  
- `'full'`: complete graph  

Topology is selected via `params.m → p.topology_type`.

### Noise Configuration
Simulations can be run with or without noise:
- **Leader noise**: Gaussian noise added to leader output (`η₀`)  
- **Agent noise**: Individually configurable per agent (vector of sensitivities)  

---

## 📊 Analysis

Results are stored in `/analysis` and include:

- Time responses (positions, errors)
- Disagreement error evolution
- Effects of noise, topology and reference type
- Comparison between Local and Neighborhood observers

---

