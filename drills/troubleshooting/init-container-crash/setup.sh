#!/bin/bash

# Cleanup
kubectl delete pod site-init --ignore-not-found

# Create broken pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: site-init
spec:
  containers:
  - name: nginx
    image: nginx:alpine
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', 'exittt 1']
EOF

# Note: 'exittt' is a typo, triggering failure.
