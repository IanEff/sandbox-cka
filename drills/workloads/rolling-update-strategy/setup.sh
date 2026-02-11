#!/bin/bash
# Setup: Create namespace and deployment

kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f - &>/dev/null

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        ports:
        - containerPort: 80
EOF

# Wait for deployment to be ready
kubectl wait --for=condition=available --timeout=60s deployment/web-app -n production &>/dev/null || true

echo "Created deployment web-app in production namespace"
exit 0
