#!/bin/bash
set -e

# Pick a node (prefer worker, fallback to any)
NODE=$(kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name | grep -v control-plane | head -n 1)
if [ -z "$NODE" ]; then
    NODE=$(kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name | head -n 1)
fi

echo "Setting up drill on node: $NODE"

# Taint and Label the node
kubectl taint nodes "$NODE" restricted=true:NoSchedule --overwrite
kubectl label nodes "$NODE" type=restricted --overwrite

# Create Deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: precious-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: precious
  template:
    metadata:
      labels:
        app: precious
    spec:
      nodeSelector:
        type: restricted
      containers:
      - name: nginx
        image: nginx:alpine
EOF
