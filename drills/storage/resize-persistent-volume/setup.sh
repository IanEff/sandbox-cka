#!/bin/bash
# Ensure local-path supports expansion for this drill
kubectl patch storageclass local-path -p '{"allowVolumeExpansion": true}'

kubectl delete pvc resize-me-pvc --ignore-not-found
kubectl delete pod resize-me-pod --ignore-not-found

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: resize-me-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Mi
  storageClassName: local-path
---
apiVersion: v1
kind: Pod
metadata:
  name: resize-me-pod
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: resize-me-pvc
EOF
