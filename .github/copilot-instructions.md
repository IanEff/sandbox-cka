# Copilot Instructions (sandbox-kcna)

This project is a Kubernetes study sandbox utilizing a **Vagrant/VirtualBox kubeadm cluster** ("ubukubu") and a custom **Drill Engine** (`drill.py`) for CKA/KCNA prep.

## 🏗 Architecture & Infrastructure
- **Stack**: Ubuntu 24.04, Kubernetes v1.34.
- **NetworkingStack**: 
  - **CNI**: Cilium v1.18+ (eBPF datapath).
  - **Mode**: `kubeProxyReplacement=true` (Required for Gateway API).
  - **LoadBalancer**: MetalLB in Layer 2 ARP mode.
- **Vagrant**: `Vagrantfile` provisions `ubukubu-control` (192.168.56.10) and worker nodes via `scripts/{common,control-plane,node}.sh`.
- **Host Integration**: 
  - `scripts/manage_k8s_config.py` merges cluster config into host `~/.kube/config` (context: `ubukubu`) and updates `~/.ssh/config`.
  - `/vagrant` in the VM mounts the project root.

## 🛠 Critical Workflows
- **Cluster Lifecycle**:
  - Start: `vagrant up` -> `python3 scripts/manage_k8s_config.py add` -> `kubectl config use-context ubukubu`.
  - Debug: `vagrant ssh ubukubu-control` (primary interaction point).
- **Drill Engine**:
  - **Runner**: `drill.py` (CLI app using `cyclopts`/`rich`/`uv`).
  - **Commands**: 
    - `uv run drill.py list`: View status.
    - `uv run drill.py start <category>/<name>`: Deploys drill resources.
    - `uv run drill.py verify [<category>/<name>]`: Runs validation checks.

## 📏 Development & Drill Conventions
**Drill Contract** (`drills/<category>/<name>/`):
1.  **`problem.md`**: Defines the task. **Must not** include solution steps. Use ambiguous but solvable requirements.
2.  **`setup.sh`**: **Idempotent** Bash script. Creates the initial state (often broken). Runs on control plane.
    - *Example*: `kubectl create ns test --dry-run=client -o yaml | kubectl apply -f -`
3.  **`verify.sh`**: **Non-interactive** verification.
    - Must exit **0** for success, **non-zero** for failure.
    - **Crucial**: Use `timeout` for all network checks (e.g., `timeout 2 nc -zv 10.96.0.1 80`).
    - *Anti-pattern*: `kubectl get pods` (visual check only). *Pattern*: `kubectl wait --for=condition=ready pod -l app=nginx`.
    - **File Location**: Place all drill-related files (scripts, manifests) in the control node`s home directory (`~` / `/home/vagrant`). Avoid using system paths like `/opt/` unless essential.

**Available Cluster Resources for Drills**:
- **Cilium**: 
    - Installed with `gatewayAPI.enabled=true` and `kubeProxyReplacement=true`.
    - Supports standard NetworkPolicies and CiliumNetworkPolicies.
- **Gateway API**:
    - **Implementation**: Cilium Gateway (embedded).
    - **GatewayClass**: `cilium`.
    - **CRDs**: **Experimental** v1.2.0 (Includes `TLSRoute`, `TCPRoute`, `UDPRoute`).
    - **API Versions**: Use `gateway.networking.k8s.io/v1` for Gateway/HTTPRoute.
- **MetalLB**: 
    - Mode: Layer 2 (ARP).
    - IP Range: `192.168.56.200` - `192.168.56.240`.
    - Automatically announces LoadBalancer IPs.
- **Storage**: 
    - **CSI**: Rancher Local Path Provisioner.
    - **Default Class**: `local-path`.
    - **Extra Disk**: 20GB mounted at `/data` (all nodes).
      - `/data/containerd` → bind-mounted to `/var/lib/containerd` (container images/data).
      - `/data/local-path-provisioner` → PersistentVolume storage.
    - ConfigMap: `local-path-config` in `local-path-storage` namespace configures path.
- **Metrics**: Metrics Server installed for HPA and top.

**Tools & Scripts**:
- **Python**: `drill.py` is modern (3.14+), managed by `uv`. Infra scripts (`scripts/*.py`) should prioritize stability.
- **Manifests**: Store reference YAML in `declarative_imperatives/`.
- **Curriculum & Sources**: 
  - Base drills off `CKA_exam_cirriculum_v1.34.md`.
  - **PRIORITY**: Reference `killer-sh-questions.md` **every time** to ensure exam-grade difficulty/style.
  - Use expert knowledge.
- **Tracking**: Update `MANIFEST--ROBOT_EYES_ONLY.md` when introducing new drills.

## ⚠️ Safety
- **Timeouts**: If terminal hangs during K8s commands, use `Ctrl+C`. `verify.sh` scripts must never hang indefinitely.
- **State**: The cluster is mutable. `drill.py reset` cleans drill state tracking, but does not revert cluster changes (manual `kubectl delete` often required).
