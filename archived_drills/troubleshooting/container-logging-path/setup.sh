#!/bin/bash
NS="trouble-logs"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Create the "broken" pod that logs to a file
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: logger
  namespace: $NS
spec:
  containers:
  - name: heavy-writer
    image: busybox
    command: ["sh", "-c", "mkdir -p /var/log && while true; do echo 'System operational at \$(date)' >> /var/log/app.log; sleep 2; done"]
EOF
