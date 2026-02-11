#!/bin/bash
set -e

# Create PV
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: manual-pv
spec:
  capacity:
    storage: 100Mi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /tmp/manual-data
EOF

# Create PVC (Request > PV Capacity)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: manual-pvc
  namespace: default
spec:
  storageClassName: manual
  volumeName: manual-pv
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200Mi
EOF
