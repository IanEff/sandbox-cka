#!/bin/bash
set -e

# Create namespace
kubectl create namespace vault --dry-run=client -o yaml | kubectl apply -f -

# Create secret with database credentials
kubectl create secret generic db-credentials \
  --from-literal=username=dbadmin \
  --from-literal=password=s3cur3P@ssw0rd \
  -n vault \
  --dry-run=client -o yaml | kubectl apply -f -

# Create pod WITHOUT secret mount (broken state)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  namespace: vault
spec:
  containers:
  - name: app
    image: busybox:latest
    command: ['sh', '-c', 'while true; do sleep 3600; done']
EOF

# Wait for pod to be running
kubectl wait --for=condition=ready pod/secure-app -n vault --timeout=60s || true

echo "Setup complete. Pod 'secure-app' needs secret mounted at /etc/db-creds/"
