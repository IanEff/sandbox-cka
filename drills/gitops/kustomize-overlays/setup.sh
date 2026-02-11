#!/bin/bash

# Setup for Kustomize Overlay Drill

BASE_DIR="/home/vagrant/kustomize-lab"
mkdir -p "$BASE_DIR/base"
mkdir -p "$BASE_DIR/overlays/prod"

# cleanup if needed
kubectl delete ns k2-prod --ignore-not-found

# Create Base Resources
cat <<EOF > "$BASE_DIR/base/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.24
EOF

cat <<EOF > "$BASE_DIR/base/kustomization.yaml"
resources:
- deployment.yaml
EOF

echo "Setup complete. Workspace: $BASE_DIR"
