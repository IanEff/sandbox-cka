#!/bin/bash
# cluster/kustomize-deployment/setup.sh
# Create a workspace directory and some base files
mkdir -p /home/vagrant/kustomize-drill/base
mkdir -p /home/vagrant/kustomize-drill/overlays/prod

# Create base resources
cat <<EOF > /home/vagrant/kustomize-drill/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loop-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: loop-app
  template:
    metadata:
      labels:
        app: loop-app
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["sh", "-c", "while true; do sleep 3600; done"]
EOF

cat <<EOF > /home/vagrant/kustomize-drill/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
EOF
