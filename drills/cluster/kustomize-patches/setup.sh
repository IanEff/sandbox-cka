#!/bin/bash
# Setup for kustomize-patches

WORK_DIR="$HOME/kust-patch-drill"
rm -rf $WORK_DIR
mkdir -p $WORK_DIR

cat <<EOF > $WORK_DIR/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sleep-deploy
  labels:
    app: sleep
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sleep
  template:
    metadata:
      labels:
        app: sleep
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        # Problem: Needs to be patched to run sleep command
EOF

cat <<EOF > $WORK_DIR/kustomization.yaml
resources:
- deployment.yaml
EOF

kubectl delete deploy sleep-deploy 2>/dev/null || true
