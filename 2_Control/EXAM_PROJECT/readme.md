# Distributed Control of Multi-Agent Magnetic Levitation Systems

This repository contains a modular MATLAB implementation of a distributed control system for a multi-agent network of magnetic levitation (maglev) systems.

The project is developed for the **Part II CPS course project** and focuses on:

- Cooperative tracking of a leader by multiple follower agents
- Comparison between **local** and **neighborhood** observers
- Simulation of different network topologies
- Analysis of performance under varying parameters and noise

---

## 📁 Project Structure
/Maglev_Project
│
├── /topologies # Contains scripts for generating and managing network topologies
│ ├── generate_topology.m # Script to generate network topologies
│ 
├── /control # Contains the files for the distributed control logic
│ ├── control.m # Main control logic for the maglev system
│
├── /simulation # Contains Simulink files and simulation models
│ ├── Maglev_sim_1.slx # Simulink model for the maglev system
│ ├── Maglev_sim_2.slx # Another Simulink model for variations
│
├── /utils # General utilities for the project
│ ├── plot_results.m # Script to plot the results from simulations
│ ├── params.m # General project parameters
│
├── main.m # Entry point for the project
