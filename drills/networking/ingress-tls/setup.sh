#!/bin/bash
set -e

# Create namespace
kubectl create namespace web --dry-run=client -o yaml | kubectl apply -f -

# Create backend deployment and service
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: web
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
EOF

# Create Ingress WITHOUT TLS (broken state)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  namespace: web
spec:
  ingressClassName: cilium
  rules:
  - host: webapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp-service
            port:
              number: 80
EOF

# Wait for deployment
kubectl wait --for=condition=available deployment/webapp -n web --timeout=60s || true

echo "Setup complete. Ingress 'webapp-ingress' exists but needs TLS configuration"
