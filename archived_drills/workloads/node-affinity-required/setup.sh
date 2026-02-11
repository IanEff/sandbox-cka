#!/bin/bash
NS="affinity-test"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Clean up any existing label on nodes (idempotency)
kubectl label nodes --all disk- > /dev/null 2>&1

# Create Deployment with required NodeAffinity
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: picky-app
  namespace: $NS
spec:
  replicas: 1
  selector:
    matchLabels:
      app: picky
  template:
    metadata:
      labels:
        app: picky
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: disk
                operator: In
                values:
                - ssd
      containers:
      - name: nginx
        image: nginx:alpine
EOF
