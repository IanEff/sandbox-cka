# CKA Study Sandbox ("Ubukubu")

![Status](https://img.shields.io/badge/CKA-PASSED-success?style=for-the-badge&logo=kubernetes)

This repository contains the study environment and "Drill Engine" used to prepare for and pass the **Certified Kubernetes Administrator (CKA)** exam (v1.34).

It features a fully automated ephemeral cluster ("ubukubu") and a custom CLI tool to generate, deploy, and verify practice scenarios.

## 🏗 Architecture

### Infrastructure ("Ubukubu")

The lab runs on local Virtual Machines provisioned via Vagrant.

* **OS**: Ubuntu 24.04 LTS (Noble Numbat)
* **Kubernetes**: v1.34 (kubeadm)
* **Networking**: Cilium CNI (strict ARP L2 mode, Gateway API enabled, `kubeProxyReplacement=true`)
* **Load Balancing**: MetalLB (Layer 2)

| VM Name | IP | Role |
| :--- | :--- | :--- |
| `ubukubu-control` | `192.168.56.10` | Control Plane |
| `ubukubu-worker` | `192.168.56.11` | Worker Node |

### The Drill Engine (`drill.py`)

A custom Python CLI tool that manages the lifecycle of practice problems. It simulates the CKA exam environment by breaking the cluster and asking you to fix it, or asking you to build resources to specific requirements.

## 🚀 Getting Started

### Prerequisites

* **Vagrant** & **VirtualBox**
* **Python 3.12+** & **[uv](https://github.com/astral-sh/uv)** (Python package manager)

### 1. Spin up the Cluster

Provision the VMs. This takes about 5-10 minutes.

```bash
vagrant up
```

* `vagrant halt`: Pause the VMs.
* `vagrant destroy -f`: Tear down everything.

Once up, config is automatically merged into your host's `~/.ssh/config` and `~/.kube/config`.

```bash
kubectl config use-context ubukubu
kubectl get nodes
```

### 2. Enter the Dojo

Most work is done directly on the control plane node, mimicking the exam's bastion host.

```bash
vagrant ssh ubukubu-control
```

## 🛠 Using the Drill Engine

The `drill.py` script is the heart of this repo. It uses `uv` to manage dependencies seamlessly.

### List Available Drills

See all drills grouped by CKA curriculum domain.

```bash
uv run drill.py list
```

### Start a Drill

Deploys resources to the cluster (often in a broken state) and prints the "Problem Statement".

```bash
# Syntax: uv run drill.py start <category>/<name>
uv run drill.py start troubleshooting/pod-pending-resource-limits
```

### Verify Your Solution

Runs validation scripts against your work. Returns `Pass` (0) or `Fail` (1).

```bash
uv run drill.py verify
```

### Clean Up / Reset

Clear the current drill state (Note: this resets the tracking, but you may need to manually delete resources if the drill was destructive).

```bash
uv run drill.py reset
```

## 📂 Repository Structure

The salient directories for the engine are:

* **`drill.py`**: The Drill Engine runner.
* **`drills/`**: The catalog of exercises. Each drill contains a `problem.md` (task), `setup.sh` (break the cluster), and `verify.sh` (grade the solution).
* **`scripts/`**: Infrastructure provisioning scripts.
* **`declarative_imperatives/`**: Reference library of "perfect" YAML manifests used for study.
* **`Vagrantfile`**: Infrastructure definition.

## 🎓 Curriculum

Drills are mapped to the standard CKA/CKAD domains:

* Cluster Architecture, Installation & Configuration
* Workloads & Scheduling
* Services & Networking (Cilium/Gateway API focus)
* Storage (Local Path Provisioner)
* Troubleshooting (The fun stuff)
