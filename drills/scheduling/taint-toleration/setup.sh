#!/bin/bash
set -e

kubectl create ns drill-scheduling --dry-run=client -o yaml | kubectl apply -f -

# Taint the node (idempotent-ish)
kubectl taint nodes ubukubu-control restricted=true:NoSchedule --overwrite

# Create Deployment pinned to CP but missing toleration
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monitor-agent
  namespace: drill-scheduling
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monitor-agent
  template:
    metadata:
      labels:
        app: monitor-agent
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - ubukubu-control
      containers:
      - name: nginx
        image: nginx:alpine
EOF
