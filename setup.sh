#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 1. Start Infrastructure (Cache + LB)
log "Checking/Starting local infrastructure..."
bash scripts/infra.sh up

# 2. Prepare Infra Directory for Artifacts
# We use this to store large downloads like ISOs or keys to avoid re-downloading inside VMs
mkdir -p infra/artifacts

# 3. Vagrant Up
log "Provisioning VMs..."
# Check if vagrant is installed
if ! command -v vagrant &> /dev/null; then
    echo "Error: vagrant could not be found."
    exit 1
fi

vagrant up

# 4. Fetch Kubeconfig
log "Retrieving Kubeconfig from Control Plane..."
mkdir -p ~/.kube

# Backup existing config if it exists and isn't a symlink or empty
if [ -f ~/.kube/config ]; then
    cp ~/.kube/config ~/.kube/config.bak
    warn "Existing ~/.kube/config backed up to ~/.kube/config.bak"
fi

# Fetch from VM. We use 'vagrant ssh' to cat the file.
# Note: The VM path is /etc/kubernetes/admin.conf or /home/vagrant/.kube/config
vagrant ssh ubukubu-control -c "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config.tmp

# Fix permissions
chmod 600 ~/.kube/config.tmp

# Fix Server URL
# The internal IP is 192.168.56.10. This is reachable from the host.
# No change needed usually if the cert allows the IP. 
# Kubeadm certs usually include the IP if --apiserver-advertise-address is set.
mv ~/.kube/config.tmp ~/.kube/config

success "Cluster is ready!"
echo ""
echo "Try running: kubectl get nodes"
