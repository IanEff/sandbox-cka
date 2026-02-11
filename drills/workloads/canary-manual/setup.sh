#!/bin/bash
kubectl create ns canary-ops --dry-run=client -o yaml | kubectl apply -f -

# Clean existing
kubectl delete deploy canary-deploy -n canary-ops --ignore-not-found
kubectl delete deploy main-deploy -n canary-ops --ignore-not-found
kubectl delete svc app-svc -n canary-ops --ignore-not-found

# Create Resources via heredoc for reliability
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: app-svc
  namespace: canary-ops
spec:
  selector:
    app: main
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: main-deploy
  namespace: canary-ops
spec:
  replicas: 3
  selector:
    matchLabels:
      app: main
  template:
    metadata:
      labels:
        app: main
    spec:
      containers:
      - name: nginx
        image: nginx:1.26
EOF
