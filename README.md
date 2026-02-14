# CKA Study Sandbox

A disposable Kubernetes cluster and drill engine for CKA exam prep. Run `vagrant up`, get a multi-node kubeadm cluster with production-grade networking, and start solving practice problems.

![CKA Lab Spec](assets/CKA-lab-spec.png)

## Prerequisites

* **Vagrant** (2.3+) & **VirtualBox**
* **Python 3.12+** & **[uv](https://github.com/astral-sh/uv)**

## Quick Start

```bash
vagrant up
kubectl config use-context ubukubu
kubectl get nodes
```

This provisions a control plane and 3 worker nodes (configurable). Cluster kubeconfig is automatically merged into `~/.kube/config`.

```bash
# SSH into the control plane (mimics the exam bastion host)
vagrant ssh ubukubu-control
```

## Cluster Configuration

All configuration is done via environment variables, read by the `Vagrantfile` at provision time.

### Nodes

| Variable | Default | Description |
| :--- | :--- | :--- |
| `SANDBOX_NUM_WORKER_NODES` | `3` | Number of worker nodes to provision |
| `SANDBOX_CONTROL_PLANE_IP` | `192.168.56.10` | Control plane IP address |
| `SANDBOX_WORKER_IP_BASE` | `20` | Workers get IPs `192.168.56.{base+n}` (e.g. `.21`, `.22`, `.23`) |

```bash
# Example: single worker node
SANDBOX_NUM_WORKER_NODES=1 vagrant up
```

### Kubernetes & CNI

| Variable | Default | Description |
| :--- | :--- | :--- |
| `SANDBOX_KUBERNETES_VERSION_MINOR` | `1.34` | Kubernetes minor version |
| `SANDBOX_CNI_PLUGIN` | `cilium` | CNI plugin (`cilium`, `flannel`, `calico`, `weavenet`) |

### Optional Add-ons

Toggle cluster add-ons on (`1`) or off (`0`). These run as provisioner scripts on the control plane.

| Variable | Default | What it installs |
| :--- | :--- | :--- |
| `SANDBOX_INSTALL_METRICS_SERVER` | `1` | Metrics Server (required for `kubectl top` / HPA) |
| `SANDBOX_INSTALL_LOCAL_PATH_PROVISIONER` | `1` | Rancher Local Path Provisioner (`local-path` StorageClass) |
| `SANDBOX_INSTALL_METALLB` | `1` | MetalLB L2 load balancer (`192.168.56.200-240`) |
| `SANDBOX_INSTALL_GATEWAY_API` | `1` | Gateway API CRDs (experimental v1.2.0, used by Cilium) |
| `SANDBOX_INSTALL_PROMETHEUS` | `1` | Prometheus monitoring stack |
| `SANDBOX_INSTALL_INGRESS_NGINX` | `0` | NGINX Ingress Controller |
| `SANDBOX_INSTALL_LONGHORN` | `0` | Longhorn distributed storage |
| `SANDBOX_INSTALL_ENVOY_GATEWAY` | `0` | Envoy Gateway |
| `SANDBOX_INSTALL_ARGOCD` | `0` | Argo CD |

```bash
# Example: minimal cluster (no MetalLB, no Prometheus)
SANDBOX_INSTALL_METALLB=0 SANDBOX_INSTALL_PROMETHEUS=0 vagrant up
```

### Local Cache (Optional)

If you're iterating on `vagrant destroy` / `vagrant up` cycles, a local APT + OCI registry cache on the host dramatically speeds up provisioning. Enabled by default (set `SANDBOX_CACHE_ENABLED=0` to disable).

| Variable | Default | Description |
| :--- | :--- | :--- |
| `SANDBOX_CACHE_ENABLED` | `1` | Use host-side APT and registry caches |
| `SANDBOX_K8S_CACHE_ENABLED` | `0` | Also cache `registry.k8s.io` images |
| `SANDBOX_CACHE_HOST_VM` | `192.168.56.1` | Host IP as seen from VMs |
| `SANDBOX_CACHE_APT_PORT` | `3142` | APT cache port (apt-cacher-ng) |
| `SANDBOX_CACHE_REGISTRY_DOCKERHUB_PORT` | `5001` | Docker Hub mirror port |
| `SANDBOX_CACHE_REGISTRY_K8S_PORT` | `5002` | registry.k8s.io mirror port |
| `SANDBOX_CACHE_REGISTRY_GHCR_PORT` | `5003` | ghcr.io mirror port |
| `SANDBOX_CACHE_REGISTRY_QUAY_PORT` | `5004` | quay.io mirror port |

## The Drill Engine

`drill.py` is a CLI tool that deploys practice problems to the cluster and verifies your solutions.

```bash
uv run drill.py list                                  # Browse available drills
uv run drill.py start troubleshooting/broken-pod      # Deploy a drill
uv run drill.py verify                                # Check your solution
uv run drill.py reset                                 # Clear drill state
```

Each drill lives in `drills/<category>/<name>/` and contains:

* `problem.md` — the task description
* `setup.sh` — idempotent script that creates the initial (often broken) cluster state
* `verify.sh` — non-interactive validation (exit 0 = pass)

### Drill Categories

Drills are organized by CKA curriculum domain:

`architecture` · `cluster` · `gitops` · `networking` · `rbac` · `scheduling` · `security` · `storage` · `troubleshooting` · `workloads`

## Repository Structure

```
drill.py              CLI drill engine
drills/               Practice problems (setup, verify, problem statement)
scripts/              VM provisioning scripts
declarative_imperatives/  Reference YAML manifests
Vagrantfile           Infrastructure definition
```

## Cluster Lifecycle

```bash
vagrant up              # Provision and start the cluster
vagrant halt            # Pause the VMs (preserves state)
vagrant destroy -f      # Tear down everything
vagrant ssh ubukubu-control   # SSH to control plane
```
