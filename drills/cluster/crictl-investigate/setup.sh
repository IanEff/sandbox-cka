#!/bin/bash
# Deploy a pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: mystery-pod
  namespace: default
spec:
  nodeName: ubukubu-control # Force scheduling on the node where we run the drill/crictl
  containers:
  - name: secret-container
    image: nginx:alpine
EOF

# Ensure /opt exists and is writable (or use a temp location, but /opt matches killer.sh style)
sudo touch /opt/mystery-id.txt
sudo chmod 666 /opt/mystery-id.txt
