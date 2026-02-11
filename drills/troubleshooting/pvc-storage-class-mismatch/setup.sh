#!/bin/bash
set -e

# Cleanup
kubectl delete ns storage-issue --ignore-not-found

# Create Namespace
kubectl create ns storage-issue

# Create PVC with a non-existent StorageClass
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-pvc
  namespace: storage-issue
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: premium-ssd-nonexistent
  resources:
    requests:
      storage: 1Gi
EOF

# Create Pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
  namespace: storage-issue
spec:
  containers:
  - name: db
    image: nginx:alpine
    volumeMounts:
    - mountPath: "/data"
      name: my-storage
  volumes:
  - name: my-storage
    persistentVolumeClaim:
      claimName: db-pvc
EOF

echo "Setup complete. Pod 'db-pod' is pending due to storage issues."
