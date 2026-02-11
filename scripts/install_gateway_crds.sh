#!/bin/bash
set -e

# NOTE: For a full Gateway controller installation (Envoy Gateway), 
# consider using scripts/install_envoy_gateway.sh instead.

echo "[GATEWAY CRDS] Installing Gateway API CRDs..."

MANIFEST_URL="https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml"


echo "Installing Gateway API CRDs from ${MANIFEST_URL}..."
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply --server-side -f ${MANIFEST_URL}

echo "[GATEWAY CRDS] Installation complete."