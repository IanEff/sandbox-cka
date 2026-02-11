#!/bin/bash
kubectl create ns workloads-1 --dry-run=client -o yaml | kubectl apply -f -

# Force delete to ensure we can recreate the broken state if it was fixed
kubectl delete pod logger -n workloads-1 --force --grace-period=0 --ignore-not-found

# Create the base pod manifest
# We use apply -f - to create it.
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: logger
  namespace: workloads-1
spec:
  containers:
  - name: app
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      while true; do
        echo "\$(date) - processing transaction..." >> /var/log/legacy-app.log;
        sleep 1;
      done
    volumeMounts:
    - name: log-vol
      mountPath: /var/log
  volumes:
  - name: log-vol
    emptyDir: {}
EOF
