# sandbox-kcna Infrastructure (Infra)

This directory contains the shared infrastructure services running on the host machine to support the Vagrant VMs.

**Services:**
1. **Local Cache** (APT Proxy + OCI Registry Mirrors) - Speeds up provisioning and saves bandwidth.
2. **Load Balancer** (HAProxy) - Provides a stable endpoint for the Kubernetes Control Plane.

## Services + Ports

| Service | Host Port (localhost) | Description |
| :--- | :--- | :--- |
| **Load Balancer** | `6443` | HAProxy forwarding to Control Plane nodes |
| LB Stats | `8404` | HAProxy Statistics UI |
| APT Cache | `3142` | `apt-cacher-ng` for Debian packages |
| Registry: Docker Hub | `5001` | Mirror for `docker.io` |
| Registry: K8s | `5002` | Mirror for `registry.k8s.io` |
| Registry: GHCR | `5003` | Mirror for `ghcr.io` |
| Registry: Quay | `5004` | Mirror for `quay.io` |

## Usage

**Manager Script:** `scripts/infra.sh`

```bash
# Start all infrastructure
bash scripts/infra.sh up

# Check status
bash scripts/infra.sh status

# View logs
bash scripts/infra.sh logs

# Stop infrastructure
bash scripts/infra.sh down
```

## Architecture

### Networking
The stack uses `network_mode: host`, meaning services bind directly to the Mac's network interfaces.
- **Access from Host**: `localhost:<port>`
- **Access from VMs**: `192.168.56.1:<port>` (The VirtualBox Host-Only Adapter IP)

### HAProxy Load Balancer
- **Frontend**: `*:6443` (TCP)
- **Backends**:
    - `192.168.56.10:6443` (Control Plane 1)
    - `192.168.56.41:6443` (Control Plane 2)
    - `192.168.56.42:6443` (Control Plane 3)

### Caching
- **APT**: Proxies requests to Ubuntu archives.
- **Registries**: Configured as pull-through caches. The VMs' containerd config points to these ports.

## Troubleshooting
- **Port Conflicts**: Ensure ports `6443`, `8404`, `3142`, and `5001-5004` are free on your Mac.
- **Connectivity**: Verify `192.168.56.1` is reachable from inside the VMs.
