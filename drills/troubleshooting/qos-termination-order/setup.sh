#!/bin/bash
# Setup for QoS Termination Order Drill
set -e

# Cleanup
kubectl delete ns project-omega --ignore-not-found=true --wait=true
rm -f /home/vagrant/pods-terminated-first.txt

# Create namespace
kubectl create ns project-omega

# Create BestEffort pods (no requests or limits)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: logger-alpha
  namespace: project-omega
spec:
  containers:
  - name: main
    image: busybox:1
    command: ["sleep", "3600"]
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cache-temp
  namespace: project-omega
spec:
  containers:
  - name: main
    image: busybox:1
    command: ["sleep", "3600"]
EOF

# Create Burstable pod (has requests but no limits, or limits != requests)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: worker-beta
  namespace: project-omega
spec:
  containers:
  - name: main
    image: busybox:1
    command: ["sleep", "3600"]
    resources:
      requests:
        memory: "64Mi"
        cpu: "50m"
EOF

# Create Guaranteed pod (requests == limits for all containers)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: db-primary
  namespace: project-omega
spec:
  containers:
  - name: main
    image: busybox:1
    command: ["sleep", "3600"]
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "100m"
EOF

# Another BestEffort
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: analytics-scratch
  namespace: project-omega
spec:
  containers:
  - name: main
    image: busybox:1
    command: ["sleep", "3600"]
EOF

# Wait for pods
kubectl wait --for=condition=ready pod --all -n project-omega --timeout=60s

echo "Setup complete."
echo "Identify BestEffort QoS pods and write names to /home/vagrant/pods-terminated-first.txt"
