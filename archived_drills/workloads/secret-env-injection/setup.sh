#!/bin/bash
NS="secure-app"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Create Deployment expecting a non-existent secret
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: $NS
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        env:
        - name: APP_TOKEN
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: API_KEY
EOF
