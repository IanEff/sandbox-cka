#!/bin/bash
kubectl delete pod huge-pod --ignore-not-found

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: huge-pod
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    resources:
      requests:
        cpu: "100"
        memory: "500Gi"
EOF
