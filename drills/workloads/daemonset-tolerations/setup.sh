#!/bin/bash

# Ensure output directory exists
mkdir -p /opt/course/3
chmod 777 /opt/course/3
rm -f /opt/course/3/count.txt

# Cleanup
kubectl delete daemonset monitoring-agent --ignore-not-found

# Create DaemonSet without toleration
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring-agent
spec:
  selector:
    matchLabels:
      name: monitoring-agent
  template:
    metadata:
      labels:
        name: monitoring-agent
    spec:
      containers:
      - name: monitoring-agent
        image: nginx:alpine
EOF
