#!/bin/bash
set -e

kubectl create ns resize-test --dry-run=client -o yaml | kubectl apply -f -

# Create a StorageClass that does NOT allow expansion (the misconfiguration)
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-resize
provisioner: kubernetes.io/no-provisioner
allowVolumeExpansion: false
volumeBindingMode: WaitForFirstConsumer
EOF

# Create a PV (simulating local storage)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-resize
  hostPath:
    path: /tmp/resize-test-data
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: Exists
EOF

# Create the PVC at 1Gi
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
  namespace: resize-test
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-resize
  resources:
    requests:
      storage: 1Gi
EOF

# Create a deployment that uses the PVC
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: data-app
  namespace: resize-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: data-app
  template:
    metadata:
      labels:
        app: data-app
    spec:
      containers:
      - name: app
        image: busybox:stable
        command: ["/bin/sh", "-c", "while true; do echo data >> /data/log.txt; sleep 60; done"]
        volumeMounts:
        - name: data-vol
          mountPath: /data
      volumes:
      - name: data-vol
        persistentVolumeClaim:
          claimName: data-pvc
EOF

echo "Setup complete. PVC data-pvc is 1Gi, need to expand to 5Gi."
