#!/bin/bash
kubectl delete ns manual-bind --ignore-not-found
kubectl create ns manual-bind
kubectl delete pv manual-disk --ignore-not-found

# Create a Pending Pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: data-writer
  namespace: manual-bind
spec:
  containers:
  - name: writer
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - mountPath: "/data"
      name: data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: manual-pvc
EOF

echo "Pod data-writer created (Pending state expected until PVC exists)."
