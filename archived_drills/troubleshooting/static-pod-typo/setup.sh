#!/bin/bash
# Create a broken static pod manifest
# We use sudo tee to write to /etc/kubernetes/manifests because it is owned by root.
cat <<EOF | sudo tee /etc/kubernetes/manifests/control-monitor.yaml > /dev/null
apiVersion: v1
kind: Pod
metadata:
  name: control-monitor
  namespace: default
spec:
  containers:
  - name: monitor
    imagee: busybox
    command: ["sleep", "3600"]
EOF

# Ensure Kubelet has a moment to react (it will fail to sync the pod)
echo "Broken static pod manifest created at /etc/kubernetes/manifests/control-monitor.yaml"
