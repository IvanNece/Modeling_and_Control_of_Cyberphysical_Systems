# Modeling and Control of Cyber-Physical Systems  
Ivan Necerini & Jacopo Rialti

This repository contains the complete project for the course *Modeling and Control of Cyber-Physical Systems* at Politecnico di Torino, Academic Year 2024/2025.

## Overview

The project is divided into two main parts:

### Part I – Secure Estimation in CPS  
This part focuses on secure state estimation and localization in the presence of sparse sensor attacks. Several scenarios are studied:
- **Static CPS estimation** using ISTA and IJAM for solving P-Lasso.
- **Target localization** under sparse attacks using weighted Lasso.
- **Dynamic CPS estimation** with SSO and D-SSO observers.
- **Target tracking** under sparse attacks in both centralized and distributed settings.

Performance is evaluated in terms of:
- State estimation error
- Support recovery accuracy (identifying attacked sensors)
- Algorithm convergence and resilience to increasing attack levels

### Part II – Distributed Control of Multi-Agent Maglev System  
This part deals with the modeling and distributed control of a network of magnetic levitation systems, including:
- Modeling each maglev as a second-order LTI system
- Designing regulators with **local** and **neighborhood** observers
- Testing various **topologies** (line, ring, mesh, fully connected)
- Analyzing the impact of:
  - Reference signal type (step, ramp, sine)
  - Tuning parameters \( c, Q, R \)
  - Measurement noise
  - Observers structure
Each configuration is evaluated through position/velocity tracking, disagreement errors, control inputs, and energy consumption.

## Reproducibility

All simulations were carried out in MATLAB and Simulink.  
# To explore the implementations, refer to the specific README files inside each part's subfolder.


