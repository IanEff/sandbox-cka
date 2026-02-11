#!/bin/bash
# Setup for Event Log Forensics Drill
set -e

# Cleanup
kubectl delete ns forensics-lab --ignore-not-found=true --wait=true
rm -f /home/vagrant/cluster-events.sh
rm -f /home/vagrant/pod-lifecycle-events.log
rm -f /home/vagrant/restart-policy.txt

# Create namespace
kubectl create ns forensics-lab

# Create deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: forensics-lab
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
EOF

kubectl wait --for=condition=available deployment/web-app -n forensics-lab --timeout=60s

echo "Setup complete."
echo "Complete the event forensics tasks and write results to the specified files."
