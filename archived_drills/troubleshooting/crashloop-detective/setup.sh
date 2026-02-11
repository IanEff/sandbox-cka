#!/bin/bash
set -e

kubectl create ns crashloop-ns --dry-run=client -o yaml | kubectl apply -f -

# Create a pod with a bad command that will crashloop
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: webapp
  namespace: crashloop-ns
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    command: ["/bin/sh", "-c", "exit 1"]
EOF

echo "Setup complete. Pod webapp is crashlooping."
