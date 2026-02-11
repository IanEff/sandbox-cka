#!/bin/bash
# Setup: Create namespace, secret, and a broken pod

kubectl create namespace apps --dry-run=client -o yaml | kubectl apply -f - &>/dev/null

# Create the secret
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=secret123 \
  --from-literal=database=myapp \
  -n apps --dry-run=client -o yaml | kubectl apply -f - &>/dev/null

# Create pod without secret configuration
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: api-server
  namespace: apps
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ['sh', '-c', 'sleep 3600']
EOF

echo "Created secret and pod without secret configuration"
exit 0
