#!/bin/bash
set -e

# Create namespace
kubectl create namespace apps --dry-run=client -o yaml | kubectl apply -f -

# Create deployment with fake private image (will fail)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: private-app
  namespace: apps
spec:
  replicas: 1
  selector:
    matchLabels:
      app: private-app
  template:
    metadata:
      labels:
        app: private-app
    spec:
      containers:
      - name: app
        image: privateregistry.example.com/myapp:v1.0
        ports:
        - containerPort: 8080
EOF

# Wait a moment for the ImagePullBackOff to occur
sleep 5

echo "Setup complete. Deployment 'private-app' has pods in ImagePullBackOff state"
echo "Fix the image pull issue by either:"
echo "  1. Creating a docker-registry secret and adding imagePullSecrets"
echo "  2. Changing to a valid public image"
