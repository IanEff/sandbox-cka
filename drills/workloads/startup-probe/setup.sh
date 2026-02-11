#!/bin/bash
set -e

# Cleanup
kubectl delete deploy legacy-app --ignore-not-found

# Deploy a "slow" app that simulates a long startup
# We use a simple shell script in busybox that sleeps 40s then starts a simple nc server
# The liveness probe is aggressive (initialDelay 5s) so it should kill it unless startup probe is added.
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-app
  labels:
    app: legacy-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: legacy-app
  template:
    metadata:
      labels:
        app: legacy-app
    spec:
      containers:
      - name: legacy-app
        image: busybox
        command: ["/bin/sh", "-c"]
        # Sleep 40s, then start a fake server on 8080
        args:
        - |
          echo "Starting legacy app..."
          sleep 40
          echo "App ready!"
          mkdir -p /tmp/health
          touch /tmp/health/ok
          while true; do echo -e "HTTP/1.1 200 OK\n\nI am alive" | nc -l -p 8080; done
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 2
          failureThreshold: 1
EOF
