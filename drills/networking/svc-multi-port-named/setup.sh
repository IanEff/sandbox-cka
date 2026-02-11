#!/bin/bash
set -e

# Idempotent Setup
kubectl create ns multi-port --dry-run=client -o yaml | kubectl apply -f -

# Create the Pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: web-backend
  namespace: multi-port
  labels:
    app: backend
spec:
  containers:
  - name: backend
    image: nginx:alpine
    ports:
    - name: http-backend
      containerPort: 80
    - name: https-backend
      containerPort: 443
    # Nginx listens on 80/443 by default inside container. 
    # To simulate 8080/8443 we'd need config. 
    # For simplicity, let's map Service 80 -> Pod 80 (named http-backend) and Service 443 -> Pod 443 (named https-backend)
    # The drill asks for mapping 80->http-backend and 443->https-backend.
EOF

echo "Environment ready."
