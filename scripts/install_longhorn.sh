#!/bin/bash
set -e

echo "[LONGHORN] Installing Longhorn CSI..."

# 1. Apply the manifest
# Using v1.7.2 as a stable baseline
VERSION="v1.7.2"
MANIFEST_URL="https://raw.githubusercontent.com/longhorn/longhorn/${VERSION}/deploy/longhorn.yaml"
DEST_FILE="/tmp/longhorn.yaml"

DOWNLOAD_SUCCESS=0
if [ "$SANDBOX_K8S_CACHE_ENABLED" = "1" ] && [ -n "$SANDBOX_CACHE_HOST" ]; then
    # Use the Remap-githubraw proxy
    CACHE_PROXY_URL="http://${SANDBOX_CACHE_HOST}:${SANDBOX_CACHE_APT_PORT}/githubraw.proxy/longhorn/longhorn/${VERSION}/deploy/longhorn.yaml"
    echo "Attempting to download through cache: ${CACHE_PROXY_URL}"
    if curl -s -L -f -o ${DEST_FILE} "${CACHE_PROXY_URL}"; then
        echo "Successfully downloaded through cache."
        DOWNLOAD_SUCCESS=1
    else
        echo "Cache download failed. Falling back to direct..."
    fi
fi

if [ "$DOWNLOAD_SUCCESS" -eq 0 ]; then
    echo "Downloading manifest from ${MANIFEST_URL}..."
    curl -L -f -o ${DEST_FILE} "${MANIFEST_URL}"
fi


# 2. Pre-configure Longhorn settings for "Dev Mode" (1 Replica, Low Disk Threshold)
echo "[LONGHORN] Pre-configuring Longhorn for Dev Environment (1 Replica)..."
kubectl create namespace longhorn-system --dry-run=client -o yaml | kubectl apply -f -

# Create/Update the default-setting ConfigMap
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: longhorn-default-setting
  namespace: longhorn-system
data:
  default-setting.yaml: |-
    backup-target:
    backup-target-credential-secret:
    allow-recurring-job-while-volume-detached:
    create-default-disk-labeled-nodes:
    default-data-path:
    default-data-locality:
    replica-soft-anti-affinity:
    replica-auto-balance:
    storage-over-provisioning-percentage:
    storage-minimal-available-percentage: "10"
    upgrade-checker:
    default-replica-count: "1"
    guaranteed-engine-manager-cpu:
    guaranteed-replica-manager-cpu:
    default-longhorn-static-storage-class:
    backup-store-poll-interval:
    taint-toleration:
    system-managed-components-node-selector:
    priority-class:
    auto-salvage:
    auto-delete-pod-when-volume-detached-unexpectedly:
    disable-scheduling-on-cordoned-node:
    replica-zone-soft-anti-affinity:
    node-down-pod-deletion-policy:
    allow-node-drain-with-last-healthy-replica:
    mkfs-ext4-parameters:
    disable-replica-rebuild:
    replica-replenishment-wait-interval:
    concurrent-replica-rebuild-per-node-limit:
    disable-revision-counter:
    system-managed-pods-image-pull-policy:
    allow-volume-creation-with-degraded-availability:
    auto-cleanup-system-generated-snapshot:
    concurrent-automatic-engine-upgrade-per-node-limit:
    backing-image-cleanup-wait-interval:
    backing-image-recovery-wait-interval:
    guaranteed-engine-cpu:
    guaranteed-replica-cpu:
EOF

echo "Applying manifest..."
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl apply -f "${DEST_FILE}"

echo "Waiting for Longhorn manager to roll out..."
# We won't wait for everything since it takes a while, but let's check the namespace
kubectl get ns longhorn-system || echo "Longhorn namespace created."

echo "[LONGHORN] Installation triggered. Use 'kubectl get pods -n longhorn-system -w' to monitor progress."
# Explicitly NOT making it the default StorageClass as per user request.
