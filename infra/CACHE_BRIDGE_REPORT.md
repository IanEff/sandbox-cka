# Infrastructure Workaround Report: "The Cache Bridge"

## The Problem

**Symptoms**:

1. `vagrant up` was excruciatingly slow, re-downloading 160MB+ of build tools on every run.
2. The VMs were unable to reach the local apt cache and registry mirrors, despite them running on the host.

**Root Cause**:
We are using **Finch/Lima** on macOS. Unlike Docker Desktop or OrbStack, Finch's network isolation prevents the container ports exposed on `localhost` (127.0.0.1) from being accessible to the VirtualBox VMs running on a different interface (`vboxnet0` / `192.168.56.1`).

Essentially:

- Hosts's localhost: `127.0.0.1:3142` (Where Finch put the cache)
- VM's gateway: `192.168.56.1`
- **Result**: The VMs tried to hit `192.168.56.1:3142`, found nothing listening there, timed out, and fell back to the slow public internet.

**Secondary Issue**:
Port `5000` (Docker Registry default) conflicts with macOS AirPlay Receiver ("ControlCenter"), preventing the registry from binding cleanly on the host network.

## The Solution

### 1. The Cache Bridge (`scripts/cache_bridge.py`)

I created a lightweight Python asyncio service that acts as a traffic forwarder.

- **Listens on**: `0.0.0.0` (All interfaces, including the VirtualBox bridge `192.168.56.1`)
- **Forwards to**: `127.0.0.1` (Where Finch is listening)
- **Ports Bridged**:
  - `3142` (APT Cache)
  - `5050` (Local Registry - moved from 5000)
  - `5001-5004` (Registry Mirrors)

### 2. Registry Port Move

Relocated the local registry from port `5000` to `5050` to avoid the macOS AirPlay conflict.

### 3. Automation

Updated `scripts/infra.sh` to automatically manage the bridge process alongside the containers.

## Usage

No manual changes needed. Just use the infra script as normal:

```bash
# Starts containers AND the bridge
bash scripts/infra.sh up

# Stops everything
bash scripts/infra.sh down
```

## Security & Safety Implications

**Is it safe to leave up?**
Yes, for a development environment on a private network (like your home WiFi), it is generally safe.

**Effects/Side-Effects**:

1. **LAN Exposure**: The bridge binds to `0.0.0.0`. This means anyone on your local WiFi network can technically reach these ports (`3142`, `5050`, etc.) on your laptop.
    - *Risk*: Low. They can read your cached packages or pull/push to your dev registry.
2. **Port Occupation**: These ports are now claimed on *all* your network interfaces. You cannot run another service on port `5050` or `3142` while this infrastructure is up.
