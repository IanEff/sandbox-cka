#!/bin/bash
kubectl create ns logging --dry-run=client -o yaml | kubectl apply -f -

# Initial Pod (No sidecar, creates log file in emptyDir)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: logger-app
  namespace: logging
spec:
  containers:
  - name: app
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      mkdir -p /var/log;
      while true; do
        echo "\$(date) - System OK" >> /var/log/app.log;
        sleep 1;
      done
    volumeMounts:
    - name: logs
      mountPath: /var/log
  volumes:
  - name: logs
    emptyDir: {}
EOF
