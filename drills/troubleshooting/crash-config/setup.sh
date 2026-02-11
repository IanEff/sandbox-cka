#!/bin/bash
set -e

kubectl create ns drill-crash --dry-run=client -o yaml | kubectl apply -f -

# Create the Secret with the "wrong" key
kubectl create secret generic app-secret --from-literal=DB_PASSWORD=supersecret -n drill-crash --dry-run=client -o yaml | kubectl apply -f -

# Create the deployment expecting "DB_PASS"
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-frontend
  namespace: drill-crash
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-frontend
  template:
    metadata:
      labels:
        app: web-frontend
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        command: ["/bin/sh", "-c"]
        args:
          - 'if [ -z "\$DB_PASS" ]; then echo "DB_PASS missing"; exit 1; fi; echo "Starting..."; nginx -g "daemon off;"'
        env:
        - name: DB_PASS
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: DB_PASS
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF
