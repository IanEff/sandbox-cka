#!/bin/bash
# Setup for kustomize-overlay drill

# Cleanup
kubectl delete deployment prod-nginx 2>/dev/null || true
rm -rf /opt/kustomize

# Create Kustomize structure
mkdir -p /opt/kustomize/base
mkdir -p /opt/kustomize/overlay/prod

# Base resources
cat <<EOF > /opt/kustomize/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
EOF

cat <<EOF > /opt/kustomize/base/kustomization.yaml
resources:
- deployment.yaml
EOF

# Overlay resources
cat <<EOF > /opt/kustomize/overlay/prod/kustomization.yaml
resources:
- ../../base
namePrefix: prod-
commonLabels:
  env: prod
EOF
