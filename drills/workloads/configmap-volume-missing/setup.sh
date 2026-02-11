#!/bin/bash
# workloads/configmap-volume-missing/setup.sh
# Create a pod that references a missing configmap
kubectl delete cm missing-map 2>/dev/null || true
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: broken-config
spec:
  containers:
  - name: test
    image: nginx
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: missing-map
EOF
