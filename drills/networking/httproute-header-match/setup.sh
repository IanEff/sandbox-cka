#!/bin/bash
# Setup for httproute-header-match

kubectl delete ns gateway-test 2>/dev/null || true
kubectl create ns gateway-test

# Deploy Dummy Backend (echo server)
kubectl run web --image=nginx:alpine -n gateway-test --labels=app=web
kubectl run android --image=nginx:alpine -n gateway-test --labels=app=android

kubectl expose pod web --name=web-service --port=80 -n gateway-test
kubectl expose pod android --name=android-service --port=80 -n gateway-test

kubectl wait --for=condition=ready pod --all -n gateway-test

# Create Gateway
# Note: This assumes a valid GatewayClass exists or the Gateway is accepted structurally.
# In a real exam, check 'kubectl get gatewayclass'.
GW_CLASS="cilium"
if kubectl get gatewayclass eg >/dev/null 2>&1; then
  GW_CLASS="eg"
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
    allowedRoutes:
      namespaces:
        from: Same
EOF
