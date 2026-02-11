#!/bin/bash
set -e

kubectl create ns reclaim-ns --dry-run=client -o yaml | kubectl apply -f -

# Create a PV that simulates being in Released state with a claimRef
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: archive-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /tmp/archive-data
  claimRef:
    name: old-archive-pvc
    namespace: reclaim-ns
    uid: "deadbeef-dead-beef-dead-beefdeadbeef"
EOF

echo "Setup complete. PV archive-pv is in Released state with stale claimRef."
