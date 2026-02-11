#!/bin/bash
NS="hardware-ops"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Create the deployment with affinity but don't label the node yet
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ssd-deployment
  namespace: $NS
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ssd-app
  template:
    metadata:
      labels:
        app: ssd-app
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: disktype
                operator: In
                values:
                - ssd
      containers:
      - name: nginx
        image: nginx:alpine
EOF

# Ensure node does NOT have the label initially (cleanup/reset)
NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
kubectl label node $NODE disktype- --overwrite >/dev/null 2>&1 || true
