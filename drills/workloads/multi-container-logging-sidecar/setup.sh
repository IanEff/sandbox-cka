#!/bin/bash
kubectl delete pod log-pod --ignore-not-found

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: log-pod
spec:
  containers:
  - name: main
    image: busybox
    args: [/bin/sh, -c, 'while true; do date >> /var/log/app.log; sleep 1; done']
    volumeMounts:
    - name: log-vol
      mountPath: /var/log
  volumes:
  - name: log-vol
    emptyDir: {}
EOF
