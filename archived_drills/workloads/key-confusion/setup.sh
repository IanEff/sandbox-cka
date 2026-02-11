#!/bin/bash
set -e

kubectl create ns secrets-ns --dry-run=client -o yaml | kubectl apply -f -

# Create a secret with WRONG key names (the misconfiguration)
# Deployment expects: username, password
# Secret has: user, pass
kubectl create secret generic db-credentials \
    --from-literal=user=admin \
    --from-literal=pass=supersecret123 \
    -n secrets-ns \
    --dry-run=client -o yaml | kubectl apply -f -

# Create deployment that references the correct keys (but secret has wrong keys)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: secrets-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api
        image: busybox:stable
        command: ["/bin/sh", "-c", "echo DB_USER=\$DB_USER DB_PASS=\$DB_PASS && sleep 3600"]
        env:
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASS
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
EOF

echo "Setup complete. Deployment api-server cannot start due to secret key mismatch."
