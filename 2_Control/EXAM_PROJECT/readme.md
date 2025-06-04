# 🚀 Distributed Control of Multi-Agent Magnetic Levitation Systems

This repository contains a modular MATLAB implementation of a distributed control system for a multi-agent network of magnetic levitation (maglev) systems.

The project is developed for the **Part II CPS course project** and focuses on:

- Cooperative tracking of a leader by multiple follower agents
- Comparison between **local** and **neighborhood** observers
- Simulation of different network topologies
- Analysis of performance under varying parameters and noise

---

## 📁 Project Structure

```bash
Project/
│
├── main.m                     # Main script to run simulations and collect results
│
├── plant_definition.m        # Defines the system matrices A, B, C, D for each agent
├── simulate_leader.m         # Generates the leader's reference trajectory (step, ramp, sinusoidal)
├── design_K.m                # Computes control gain K via Riccati equation
├── design_F.m                # Computes observer gain F via Riccati equation
│
├── topologies/
│   └── generate_topology.m   # Builds adjacency, Laplacian (L), and pinning (G) matrices
│
├── simulations/
│   ├── simulate_follower_local.m  # Simulates agents using local observer strategy
│   └── simulate_follower_neigh.m  # Simulates agents using neighborhood observer strategy
│
├── utils/
│   ├── plot_disagreement.m   # Plots tracking performance and error evolution
│   ├── add_noise.m           # Adds measurement noise to output data
│   └── compute_energy.m      # Computes energy of signals (e.g., disagreement error)
│
└── results/                  # Folder to store simulation outputs and plots