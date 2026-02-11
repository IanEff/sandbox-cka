#!/bin/bash
set -e

# Config
POD_CIDR="10.244.0.0/16"
CONTROL_PLANE_IP="192.168.56.10"

echo "[CONTROL PLANE] Initialize Cluster"

# Initialize Kubeadm
# We use a declarative config file located in infra/kubeadm-config.yaml
# logic has been moved to that file (Pod CIDR, Advertise Address, etc.)
if [ ! -f /etc/kubernetes/admin.conf ]; then
    kubeadm init --config /vagrant/infra/kubeadm-config.yaml --ignore-preflight-errors=NumCPU
else
    echo "[CONTROL PLANE] Cluster already initialized. Skipping kubeadm init."
fi

# Configure kubectl for root (and vagrant user)
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# Also set up for vagrant user
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

# Install Network Plugin
CNI_PLUGIN="${SANDBOX_CNI_PLUGIN:-flannel}"

if [ "$CNI_PLUGIN" = "cilium" ]; then
    echo "[CONTROL PLANE] Installing Cilium CNI..."
    # Run with bash to avoid permission issues on shared folder
    bash /vagrant/scripts/install_cilium.sh
elif [ "$CNI_PLUGIN" = "calico" ]; then
    echo "[CONTROL PLANE] Installing Calico CNI..."
    bash /vagrant/scripts/install_calico.sh
elif [ "$CNI_PLUGIN" = "weavenet" ]; then
    echo "[CONTROL PLANE] Installing Weave Net CNI..."
    bash /vagrant/scripts/install_weavenet.sh
else
    echo "[CONTROL PLANE] Installing Flannel CNI"
    kubectl apply -f /vagrant/values/kube-flannel.yml
fi

# Generate Join Script
echo "[CONTROL PLANE] Generating join script"
kubeadm token create --print-join-command > /vagrant/join.sh
chmod +x /vagrant/join.sh

# Install Helm
echo "[CONTROL PLANE] Installing Helm..."
HELM_VERSION="v3.20.0"
ARCH=$(dpkg --print-architecture) # arm64 or amd64
HELM_TARBALL="helm-${HELM_VERSION}-linux-${ARCH}.tar.gz"
HELM_URL="https://get.helm.sh/${HELM_TARBALL}"
CACHE_DIR="/vagrant/infra/artifacts"

if ! command -v helm &> /dev/null; then
    if [ -f "${CACHE_DIR}/${HELM_TARBALL}" ]; then
        echo "Found cached Helm at ${CACHE_DIR}/${HELM_TARBALL}"
        tar -zxvf "${CACHE_DIR}/${HELM_TARBALL}"
        mv "linux-${ARCH}/helm" /usr/local/bin/helm
        rm -rf "linux-${ARCH}"
    else 
        echo "Downloading Helm from ${HELM_URL}..."
        curl -fsSL -o "${HELM_TARBALL}" "${HELM_URL}"
        
        # Cache it
        if [ -d "${CACHE_DIR}" ]; then
            echo "Caching Helm to ${CACHE_DIR}/${HELM_TARBALL}"
            cp "${HELM_TARBALL}" "${CACHE_DIR}/${HELM_TARBALL}"
        fi

        tar -zxvf "${HELM_TARBALL}"
        mv "linux-${ARCH}/helm" /usr/local/bin/helm
        rm -rf "linux-${ARCH}" "${HELM_TARBALL}"
    fi
fi

