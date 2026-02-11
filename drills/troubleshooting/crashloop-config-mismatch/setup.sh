#!/bin/bash
kubectl create ns trouble --dry-run=client -o yaml | kubectl apply -f -

# Create incomplete ConfigMap
kubectl create configmap app-config --from-literal=APP_MODE=prod -n trouble --dry-run=client -o yaml | kubectl apply -f -

# Create crashing Deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-app
  namespace: trouble
spec:
  replicas: 1
  selector:
    matchLabels:
      app: broken-app
  template:
    metadata:
      labels:
        app: broken-app
    spec:
      containers:
      - name: app
        image: busybox
        command: ["/bin/sh", "-c"]
        # Script checks for DB_URL, exits 1 if not found
        args:
        - 'if [ -z "\$DB_URL" ]; then echo "Missing DB_URL"; exit 1; else echo "Connected to \$DB_URL"; sleep 3600; fi'
        envFrom:
        - configMapRef:
            name: app-config
EOF
