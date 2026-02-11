#!/bin/bash
kubectl create ns liveness-fail --dry-run=client -o yaml | kubectl apply -f -

# Create a pod that fails liveness immediately
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: slow-starter
  namespace: liveness-fail
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["/bin/sh", "-c", "sleep 15; touch /tmp/healthy; sleep 3600"]
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
EOF
