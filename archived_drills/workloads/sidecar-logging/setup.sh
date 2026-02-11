#!/bin/bash
# Setup: Create a Pod that writes logs to a file in a volume

kubectl delete pod web-server --force --grace-period=0 2>/dev/null

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: web-server
spec:
  containers:
  - name: main-app
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      while true; do
        echo "\$(date) - Request served" >> /var/log/web.log;
        sleep 5;
      done
    volumeMounts:
    - name: log-vol
      mountPath: /var/log
  volumes:
  - name: log-vol
    emptyDir: {}
EOF
