#!/bin/bash
# Setup for service-endpoints-missing

kubectl create namespace debug-me --dry-run=client -o yaml | kubectl apply -f -

# Create correct Deployment
kubectl -n debug-me create deployment web-app --image=nginx:alpine --replicas=2 --dry-run=client -o yaml | kubectl apply -f -

# Create BROKEN Service (wrong selector)
cat <<EOF | kubectl -n debug-me apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: debug-me
spec:
  selector:
    app: web-app-v2  # Typo/Misconfigure here. Real label is app=web-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF
