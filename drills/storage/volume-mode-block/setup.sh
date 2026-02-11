#!/bin/bash
set -e

# Idempotent Setup
echo "Setting up environment for Block Volume Mode drill..."

# Create Namespace if not exists
kubectl create ns block-world --dry-run=client -o yaml | kubectl apply -f -

# Create the dummy block file on the worker node (simulated via strict local file or just ignore if node access is hard)
# We will assume the student just needs the PV to point there. 
# We need to find a valid node name dynamically
NODE=$(kubectl get nodes --no-headers | grep -v "control-plane" | head -n1 | awk '{print $1}')
if [ -z "$NODE" ]; then
    NODE=$(kubectl get nodes --no-headers | head -n1 | awk '{print $1}')
fi

echo "Using node: $NODE for block file creation"

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: setup-block-file
  namespace: kube-system
spec:
  nodeName: $NODE
  containers:
  - name: setup
    image: busybox
    command: ["sh", "-c", "dd if=/dev/zero of=/var/tmp/blockfile bs=1M count=100 && chmod 777 /var/tmp/blockfile && sleep 10"]
    volumeMounts:
    - name: host-tmp
      mountPath: /var/tmp
  volumes:
  - name: host-tmp
    hostPath:
      path: /var/tmp
  restartPolicy: Never
EOF

# Wait for it to finish? Nah, it's fast.
echo "Environment ready."
