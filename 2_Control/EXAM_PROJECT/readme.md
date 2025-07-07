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
/Maglev_Project
│
├── /topologies
│ └── generate_topology.m # Generates line, ring, mesh, full topologies
│
├── /control
│ └── control.m # Designs K, F, L1, observers (LQR + Riccati)
│
├── /simulation
│ ├── Local.slx # Simulink model with local observers
│ └── Neighborhood.slx # Simulink model with cooperative observers
│
├── /utils
│ └── params.m # General project parameters (N, Q, R, etc.)
│
├── main.m # Main script: topology + simulation config


---

## 🛠️ How to Use

1. Open `params.m`, configure parameters:
   - Topology (`p.topology_type`)
   - Reference type (`p.scelta_riferimento`)
   - Noise parameters (`noise_sensitivity`, `agent_noise_sensitivity_vector`)
2. Run `main.m`
3. Open either `Local.slx` or `Neighborhood.slx`
4. Simulate and observe results

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


