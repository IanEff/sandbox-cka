#!/bin/bash
kubectl delete ns gateway-test --ignore-not-found
kubectl create ns gateway-test

# Deploy Backend
kubectl create deployment web --image=nginx:1.27 -n gateway-test
kubectl expose deployment web --port=80 -n gateway-test

# Create Gateway (prefer 'eg', fallback to others)
GW_CLASS="eg"
if ! kubectl get gatewayclass eg >/dev/null 2>&1; then
  GW_CLASS=$(kubectl get gatewayclass -o jsonpath='{.items[0].metadata.name}')
fi

cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
  namespace: gateway-test
spec:
  gatewayClassName: $GW_CLASS
  listeners:
  - name: http
    protocol: HTTP
    port: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: header-route
  namespace: gateway-test
spec:
  parentRefs:
  - name: my-gateway
  rules:
  - backendRefs:
    - name: web
      port: 80
EOF
