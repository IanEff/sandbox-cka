#!/bin/bash
# Setup for Multi-Container Log Debug Drill
set -e

# Cleanup
kubectl delete ns debug-lab --ignore-not-found=true --wait=true
rm -f /home/vagrant/failing-container.txt
rm -f /home/vagrant/crash-error.txt

# Create namespace
kubectl create ns debug-lab

# Create pod with 3 containers - processor is designed to crash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: data-pipeline
  namespace: debug-lab
spec:
  containers:
  - name: fetcher
    image: busybox:1
    command: ["sh", "-c", "echo 'Fetcher started' && while true; do echo 'fetching data...'; sleep 5; done"]
    resources:
      requests:
        cpu: 5m
        memory: 8Mi
  - name: processor
    image: busybox:1
    command: ["sh", "-c", "echo 'Processor initializing...' && sleep 1 && echo 'ERROR: config file /etc/pipeline/config.yaml not found' && exit 1"]
    resources:
      requests:
        cpu: 5m
        memory: 8Mi
  - name: exporter
    image: busybox:1
    command: ["sh", "-c", "echo 'Exporter started' && while true; do echo 'exporting results...'; sleep 5; done"]
    resources:
      requests:
        cpu: 5m
        memory: 8Mi
EOF

# Wait a few seconds for the crash to occur
sleep 8

echo "Setup complete."
echo "Pod 'data-pipeline' in namespace 'debug-lab' has a failing container."
echo "Investigate, document, and fix the issue."
