#!/bin/bash
# workloads/probes-configuration/setup.sh
# Create a pod with broken probes

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: probe-fail
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    # This file does not exist, so Liveness will fail and kill the pod repeatedly
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/nonexistent
      initialDelaySeconds: 5
      periodSeconds: 5
    # Port 81 doesnt exist, so Readiness will fail
    readinessProbe:
      httpGet:
        path: /
        port: 81
      initialDelaySeconds: 5
      periodSeconds: 5
EOF
