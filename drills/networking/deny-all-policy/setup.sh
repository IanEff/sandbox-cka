#!/bin/bash
set -e

kubectl create ns secure-drill --dry-run=client -o yaml | kubectl apply -f -

# API
kubectl run api --image=nginx:alpine --labels=app=api -n secure-drill --expose --port=80 --dry-run=client -o yaml | kubectl apply -f -

# Clients
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: secure-drill
  labels:
    app: frontend
spec:
  containers:
  - name: frontend
    image: busybox
    command: ["/bin/sh", "-c", "sleep 3600"]
  restartPolicy: Never
---
apiVersion: v1
kind: Pod
metadata:
  name: intruder
  namespace: secure-drill
  labels:
    app: intruder
spec:
  containers:
  - name: intruder
    image: busybox
    command: ["/bin/sh", "-c", "sleep 3600"]
  restartPolicy: Never
EOF
