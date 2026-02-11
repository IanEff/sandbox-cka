#!/bin/bash
kubectl create ns debug-me --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic app-config --from-literal=WRONG_KEY=supersecret -n debug-me --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-viewer
  namespace: debug-me
spec:
  replicas: 1
  selector:
    matchLabels:
      app: viewer
  template:
    metadata:
      labels:
        app: viewer
    spec:
      containers:
      - name: viewer
        image: busybox
        command: ["sh", "-c", "echo App running with \$API_KEY && sleep 3600"]
        env:
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: app-config
              key: API_KEY
EOF
