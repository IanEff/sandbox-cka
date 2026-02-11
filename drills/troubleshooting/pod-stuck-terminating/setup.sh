#!/bin/bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cant-stop
  namespace: default
  finalizers:
  - example.com/forever
spec:
  containers:
  - name: nginx
    image: nginx:alpine
EOF

# Wait for pod to count as "exists" and running so deletion triggers finalizer loop
echo "Waiting for pod to start..."
kubectl wait --for=condition=ready pod/cant-stop --timeout=60s || true

# Delete without waiting (should hang due to finalizer)
kubectl delete pod cant-stop --wait=false

