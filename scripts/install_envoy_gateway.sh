#!/bin/bash
set -e

echo "[ENVOY GATEWAY] Starting installation..."

# 1. Install Gateway API CRDs (if not already present/up-to-date)
# Using v1.2.0 as a baseline that works well with recent Envoy Gateway versions
GATEWAY_API_VERSION="v1.2.0" 
CRD_URL="https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml"

echo "[ENVOY GATEWAY] Installing Gateway API CRDs (${GATEWAY_API_VERSION})..."
kubectl apply --server-side -f "$CRD_URL"

# 2. Install Envoy Gateway
# Using v1.2.0 for stability
EG_VERSION="v1.2.0"
EG_URL="https://github.com/envoyproxy/gateway/releases/download/${EG_VERSION}/install.yaml"

echo "[ENVOY GATEWAY] Installing Envoy Gateway (${EG_VERSION})..."
kubectl apply --server-side -f "$EG_URL"

echo "[ENVOY GATEWAY] Installation applied. Pods will start in the background."
# Skipping wait to unblock Vagrant provisioning.
# kubectl wait --timeout=5m \
#    --for=condition=Available deployment/envoy-gateway \
#    -n envoy-gateway-system

# 3. Create GatewayClass
# This allows users to immediately create Gateways without defining the class themselves
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
EOF

echo "[ENVOY GATEWAY] Installation process initialized. GatewayClass 'eg' created."
