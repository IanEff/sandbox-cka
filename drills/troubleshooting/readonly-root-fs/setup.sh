#!/bin/bash
# Setup: Create a pod with readOnlyRootFilesystem that tries to write to root fs

kubectl delete pod web-logger --ignore-not-found --now

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: web-logger
  namespace: default
spec:
  containers:
  - name: logger
    image: busybox
    command: ["sh", "-c", "echo 'Starting...' > /var/log/app.log && sleep 3600"]
    securityContext:
      readOnlyRootFilesystem: true
EOF
