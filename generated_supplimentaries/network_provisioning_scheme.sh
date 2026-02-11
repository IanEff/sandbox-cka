#!/bin/bash
# CKA kubeadm init provisioner

# Network configuration
CONTROL_PLANE_IP="${CONTROL_PLANE_IP:-192.168.56.10}"
POD_CIDR="${POD_CIDR:-10.244.0.0/16}"
SERVICE_CIDR="${SERVICE_CIDR:-10.96.0.0/12}"
FLANNEL_IFACE="${FLANNEL_IFACE:-eth0}"
K8S_VERSION="${K8S_VERSION:-}"  # Leave empty for latest

# Build kubeadm init command
INIT_CMD="sudo kubeadm init --apiserver-advertise-address=${CONTROL_PLANE_IP} --pod-network-cidr=${POD_CIDR} --service-cidr=${SERVICE_CIDR}"

# Add version if specified
if [ -n "$K8S_VERSION" ]; then
  INIT_CMD="${INIT_CMD} --kubernetes-version=${K8S_VERSION}"
fi

# Initialize cluster
echo "Initializing cluster with control plane at ${CONTROL_PLANE_IP}..."
eval $INIT_CMD

# Setup kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Wait for API server
echo "Waiting for API server..."
until kubectl cluster-info &>/dev/null; do
  sleep 2
done

# Deploy Flannel with interface pinning
echo "Deploying Flannel CNI on interface ${FLANNEL_IFACE}..."
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Patch Flannel to use specific interface
kubectl -n kube-flannel patch daemonset kube-flannel-ds --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--iface='${FLANNEL_IFACE}'"
  }
]'

# Wait for Flannel pods
echo "Waiting for Flannel pods to be ready..."
kubectl wait --for=condition=ready pod -l app=flannel -n kube-flannel --timeout=120s

echo "Cluster initialized successfully!"
kubectl get nodes