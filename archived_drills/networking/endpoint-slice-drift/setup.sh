#!/bin/bash
set -e

kubectl create ns endpoint-ns --dry-run=client -o yaml | kubectl apply -f -

# Ensure clean slate for deployment
kubectl delete deployment backend -n endpoint-ns --ignore-not-found

# Create deployment with specific labels
kubectl create deployment backend --image=nginx:alpine --replicas=2 -n endpoint-ns
kubectl label deployment backend -n endpoint-ns app=backend tier=api --overwrite

# Wait for pods
kubectl rollout status deployment backend -n endpoint-ns --timeout=60s

# Create service with WRONG selector (label mismatch)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: endpoint-ns
spec:
  selector:
    app: backnd
    tier: api
  ports:
    - port: 80
      targetPort: 80
EOF

echo "Setup complete. Service has no endpoints due to selector mismatch."
