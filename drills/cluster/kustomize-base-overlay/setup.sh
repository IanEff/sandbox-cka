#!/bin/bash
# Setup for kustomize-base-overlay

WORK_DIR="$HOME/kust-drill"
rm -rf $WORK_DIR
mkdir -p $WORK_DIR/base
mkdir -p $WORK_DIR/overlays/prod

# Create Base
cat <<EOF > $WORK_DIR/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
EOF

cat <<EOF > $WORK_DIR/base/kustomization.yaml
resources:
- deployment.yaml
EOF

# Create Overlay Skeleton
cat <<EOF > $WORK_DIR/overlays/prod/kustomization.yaml
resources:
- ../../base
# TODO: Add namespace, labels, and replica patch
EOF

# Cleanup previous run
kubectl delete ns prod-ns 2>/dev/null || true
