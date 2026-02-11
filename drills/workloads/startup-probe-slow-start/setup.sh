#!/bin/bash
# Setup for startup-probe-slow-start

kubectl create namespace legacy --dry-run=client -o yaml | kubectl apply -f -

# Create "slow" app that sleeps 30s before becoming ready
# The liveness probe kills it after 10s (initialDelay 5 + period 5 * failure 1... roughly)
# Actually default failureThreshold is 3.
# Let's make it fail.
cat <<EOF | kubectl -n legacy apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-app
  namespace: legacy
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
      - name: main
        image: busybox
        # Simulate slow start: create /tmp/ready after 30s, then sleep forever
        command: ["/bin/sh", "-c", "sleep 30; touch /tmp/ready; sleep 3600"]
        livenessProbe:
          exec:
            command:
            - cat
            - /tmp/ready
          initialDelaySeconds: 5
          periodSeconds: 5
          failureThreshold: 1 # Aggressive
EOF
