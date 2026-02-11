#!/bin/bash
set -e

kubectl create ns maintenance-test --dry-run=client -o yaml | kubectl apply -f -

# Create a deployment with multiple replicas spread across nodes
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-app
  namespace: maintenance-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: critical-app
  template:
    metadata:
      labels:
        app: critical-app
    spec:
      containers:
      - name: app
        image: nginx:alpine
        ports:
        - containerPort: 80
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            app: critical-app
EOF

# Wait for deployment to be ready
echo "Waiting for critical-app deployment to be ready..."
kubectl rollout status deployment/critical-app -n maintenance-test --timeout=60s

echo "Setup complete. critical-app deployment running with 3 replicas."
echo "Your task: drain ubukubu-node-1 for maintenance, then uncordon it."
