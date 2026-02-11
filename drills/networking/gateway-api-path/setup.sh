#!/bin/bash
kubectl create ns networking-6 --dry-run=client -o yaml | kubectl apply -f -

# Ensure clean slate for the example resources
kubectl delete deployment echo -n networking-6 --ignore-not-found
kubectl delete service echo -n networking-6 --ignore-not-found
kubectl delete gateway cilium-gateway -n networking-6 --ignore-not-found
kubectl delete httproute echo-route -n networking-6 --ignore-not-found

# Service
kubectl create deployment echo --image=nginx --replicas=1 -n networking-6 --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deployment echo --port=80 -n networking-6 --dry-run=client -o yaml | kubectl apply -f -

# Gateway (assuming CRDs installed as per instructions)
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: cilium-gateway
  namespace: networking-6
spec:
  gatewayClassName: cilium
  listeners:
  - name: http
    protocol: HTTP
    port: 80
EOF
