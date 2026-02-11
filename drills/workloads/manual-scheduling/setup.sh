#!/usr/bin/env bash
set -e

# 1. Stop the scheduler by moving the static pod manifest
if [ -f /etc/kubernetes/manifests/kube-scheduler.yaml ]; then
    echo "Stopping kube-scheduler..."
    sudo mv /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/manifests/kube-scheduler.yaml.bak
fi

# 2. Create the Pending Pod
kubectl delete pod crisis-aversion --ignore-not-found
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: crisis-aversion
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx
  # No nodeName, so it needs scheduler
EOF

echo "Setup complete. Scheduler is stopped and Pod 'crisis-aversion' is Pending."
