#!/bin/bash
set -e

kubectl create ns autoscale-test --dry-run=client -o yaml | kubectl apply -f -

# Create a deployment with resource requests (required for HPA CPU metrics)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-api
  namespace: autoscale-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-api
  template:
    metadata:
      labels:
        app: web-api
    spec:
      containers:
      - name: api
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "64Mi"
          limits:
            cpu: "200m"
            memory: "128Mi"
EOF

# Wait for deployment to be ready
echo "Waiting for web-api deployment to be ready..."
kubectl rollout status deployment/web-api -n autoscale-test --timeout=60s

echo "Setup complete. web-api deployment running with 1 replica."
echo "Your task: Create an HPA named 'web-api-hpa' with min=2, max=10, target CPU=50%."
