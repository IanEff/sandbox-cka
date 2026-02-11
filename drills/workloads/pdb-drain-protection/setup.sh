#!/bin/bash
# Setup for PDB Drain Protection Drill
set -e

# Cleanup
kubectl delete ns project-lima --ignore-not-found=true --wait=true
rm -f /home/vagrant/pdb-allowed-disruptions.txt

# Create namespace
kubectl create ns project-lima

# Create deployment with 3 replicas
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-api
  namespace: project-lima
spec:
  replicas: 3
  selector:
    matchLabels:
      app: payment-api
  template:
    metadata:
      labels:
        app: payment-api
    spec:
      containers:
      - name: api
        image: nginx:1-alpine
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
EOF

kubectl wait --for=condition=available deployment/payment-api -n project-lima --timeout=60s

echo "Setup complete."
echo "Create PDB 'payment-api-pdb' in namespace 'project-lima' ensuring minimum 2 pods available."
