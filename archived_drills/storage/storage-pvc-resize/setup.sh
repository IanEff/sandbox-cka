#!/bin/bash
# Setup for storage-pvc-resize drill

# Cleanup
kubectl delete pod data-pod --force --grace-period=0 2>/dev/null || true
kubectl delete pvc data-claim 2>/dev/null || true
kubectl delete sc resizable-sc 2>/dev/null || true

# Create StorageClass
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: resizable-sc
provisioner: kubernetes.io/no-provisioner
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
EOF

# Create PV (Manual because no-provisioner)
# Actually, for drill stability in a sandbox without dynamic provisioning for custom SC,
# we might rely on 'standard' or 'hostpath' but configured to allow expansion.
# Let's assume standard hostpath provisioner is available or create a local PV.

# To simplify and ensure it works in standard Kind/Minikube/Vagrant envs,
# we will use a local PV.

kubectl delete pv local-pv-50mi 2>/dev/null || true
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-50mi
spec:
  capacity:
    storage: 200Mi # PV must be large enough to accommodate the resize request up to this limit, check validity.
                   # Actually, to resize PVC, the underlying PV must support it or be large enough?
                   # In cloud, it resizes the disk. In local static PV, the PV must be big enough?
                   # Let's make PV 200Mi, bind 50Mi PVC to it. Then resize PVC to 100Mi.
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: resizable-sc
  hostPath:
    path: /tmp/data-pv
EOF

# Create PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-claim
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: resizable-sc
  resources:
    requests:
      storage: 50Mi
EOF

# Create Pod to bind it
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: data-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - mountPath: /data
      name: data-volume
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: data-claim
EOF
