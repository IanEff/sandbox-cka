#!/bin/bash
# Verify that Local Path Provisioner is using the extra disk storage

set -e

echo "=== Storage Configuration Verification ==="
echo

# 1. Check disk mounts
echo "1. Checking disk mounts..."
echo "   Extra disk (/data):"
df -h /data 2>/dev/null || echo "   ❌ /data not mounted!"
echo
echo "   Container storage:"
df -h /var/lib/containerd | tail -n1
echo

# 2. Check local-path-provisioner directory exists
echo "2. Checking PV storage directory..."
if [ -d "/data/local-path-provisioner" ]; then
    echo "   ✓ /data/local-path-provisioner exists"
    ls -lah /data/local-path-provisioner/ | head -n5
else
    echo "   ❌ /data/local-path-provisioner not found!"
    exit 1
fi
echo

# 3. Check ConfigMap
echo "3. Checking local-path-provisioner ConfigMap..."
export KUBECONFIG=/etc/kubernetes/admin.conf
CONFIG_PATH=$(kubectl get configmap local-path-config -n local-path-storage -o jsonpath='{.data.config\.json}' 2>/dev/null | grep -o '/data/local-path-provisioner' || echo "")
if [ -n "$CONFIG_PATH" ]; then
    echo "   ✓ ConfigMap is configured for /data/local-path-provisioner"
else
    echo "   ❌ ConfigMap not configured for /data/local-path-provisioner"
    echo "   Current config:"
    kubectl get configmap local-path-config -n local-path-storage -o jsonpath='{.data.config\.json}' | jq .
    exit 1
fi
echo

# 4. Create test PVC and pod
echo "4. Creating test PVC and pod..."
kubectl create ns storage-test 2>/dev/null || true
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
  namespace: storage-test
spec:
  storageClassName: local-path
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 100Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: storage-test
spec:
  containers:
  - name: test
    image: busybox
    command: ["sh", "-c", "echo 'Storage verification test' > /data/test.txt && cat /data/test.txt && sleep 30"]
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: test-pvc
EOF

echo "   Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod/test-pod -n storage-test --timeout=60s >/dev/null

# Get PV name
PV_NAME=$(kubectl get pvc test-pvc -n storage-test -o jsonpath='{.spec.volumeName}')
echo "   ✓ PV created: $PV_NAME"
echo

# 5. Check where the data actually landed
echo "5. Verifying PV location on disk..."
PV_DIR=$(find /data/local-path-provisioner -type d -name "*storage-test_test-pvc" 2>/dev/null | head -n1)
if [ -n "$PV_DIR" ]; then
    echo "   ✓ PV directory found on extra disk: $PV_DIR"
    echo "   Content:"
    ls -lah "$PV_DIR"
    if [ -f "$PV_DIR/test.txt" ]; then
        echo "   ✓ Test file exists:"
        cat "$PV_DIR/test.txt"
    fi
else
    echo "   ❌ PV directory not found in /data/local-path-provisioner!"
    echo "   Searching elsewhere..."
    find /opt -type d -name "*storage-test_test-pvc" 2>/dev/null || echo "   Not in /opt either"
    exit 1
fi
echo

# 6. Cleanup
echo "6. Cleaning up test resources..."
kubectl delete ns storage-test --wait=false >/dev/null 2>&1
echo "   ✓ Cleanup initiated (background)"
echo

echo "=== ✅ All checks passed! Local Path Provisioner is using the extra disk. ==="
