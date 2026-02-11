#!/bin/bash

# Implement idempotent setup
NS="gateway-drill"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Create a dummy Gateway to attach to (simulating infrastructure)
# Check for Gateway API CRDs and install if missing
if ! kubectl get crd gateways.gateway.networking.k8s.io >/dev/null 2>&1; then
  echo "Gateway API CRDs not found. Installing..."
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
  echo "Waiting for Gateway API CRDs to be established..."
  kubectl wait --for=condition=established crd/gateways.gateway.networking.k8s.io --timeout=60s
fi

cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: dummy-class
spec:
  controllerName: "example.com/dummy-controller"
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: $NS
spec:
  gatewayClassName: dummy-class
  listeners:
  - name: http
    protocol: HTTP
    port: 80
EOF

# Create the application
kubectl create deployment color-app -n $NS --image=nginx:alpine --replicas=1 --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deployment color-app -n $NS --name=color-service --port=80 --target-port=80 --dry-run=client -o yaml | kubectl apply -f -
