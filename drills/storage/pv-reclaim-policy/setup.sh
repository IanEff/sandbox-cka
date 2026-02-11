#!/bin/bash
# Setup: Create a PV with Delete reclaim policy

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: important-data-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: manual
  hostPath:
    path: /tmp/important-data
EOF

echo "Created PV with Delete reclaim policy"
exit 0
