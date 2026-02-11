#!/bin/bash
set -e

kubectl create ns drill-storage --dry-run=client -o yaml | kubectl apply -f -

# Create small PVC
cat <<EOF | kubectl apply -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: small-pvc
  namespace: drill-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
EOF

# Create Pod writing data
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: data-pod
  namespace: drill-storage
  labels:
    app: data-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["/bin/sh", "-c", "echo 'DO_NOT_LOSE_THIS' > /data/important.txt; sleep 3600"]
    volumeMounts:
    - mountPath: "/data"
      name: data-vol
  volumes:
  - name: data-vol
    persistentVolumeClaim:
      claimName: small-pvc
EOF

echo "Waiting for data-pod to settle..."
kubectl wait --for=condition=ready pod -l app=data-pod -n drill-storage --timeout=30s 2>/dev/null || true
