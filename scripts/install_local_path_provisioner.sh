#!/bin/bash
set -e

echo "[LOCAL PATH PROVISIONER] Installing Rancher Local Path Provisioner..."

# 1. Apply the manifest
VERSION="v0.0.33"
MANIFEST_URL="https://raw.githubusercontent.com/rancher/local-path-provisioner/${VERSION}/deploy/local-path-storage.yaml"
DEST_FILE="/tmp/local-path-storage.yaml"

DOWNLOAD_SUCCESS=0
if [ "$SANDBOX_K8S_CACHE_ENABLED" = "1" ] && [ -n "$SANDBOX_CACHE_HOST" ]; then
    # Use the Remap-githubraw proxy
    CACHE_PROXY_URL="http://${SANDBOX_CACHE_HOST}:${SANDBOX_CACHE_APT_PORT}/githubraw.proxy/rancher/local-path-provisioner/${VERSION}/deploy/local-path-storage.yaml"
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

echo "Applying manifest..."
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl apply -f "${DEST_FILE}"

# 2. Patch StorageClass to be default
echo "Patching local-path StorageClass to be default..."
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# 3. Update ConfigMap to use the extra storage disk at /data/local-path-provisioner
# This directory is created by common.sh on the extra 20GB disk mounted at /data
echo "Updating ConfigMap to use /data/local-path-provisioner..."
kubectl apply -f - <<'EOF'
kind: ConfigMap
apiVersion: v1
metadata:
  name: local-path-config
  namespace: local-path-storage
data:
  config.json: |-
    {
      "nodePathMap": [
        {
          "node": "DEFAULT_PATH_FOR_NON_LISTED_NODES",
          "paths": ["/data/local-path-provisioner"]
        }
      ]
    }
  setup: |-
    #!/bin/sh
    set -eu
    mkdir -m 0777 -p "$VOL_DIR"
  teardown: |-
    #!/bin/sh
    set -eu
    rm -rf "$VOL_DIR"
  helperPod.yaml: |-
    apiVersion: v1
    kind: Pod
    metadata:
      name: helper-pod
    spec:
      priorityClassName: system-node-critical
      tolerations:
        - key: node.kubernetes.io/disk-pressure
          operator: Exists
          effect: NoSchedule
      containers:
      - name: helper-pod
        image: busybox
EOF

# 4. Restart the provisioner to pick up the new config
echo "Restarting local-path-provisioner to pick up config changes..."
kubectl rollout restart deployment local-path-provisioner -n local-path-storage

echo "[LOCAL PATH PROVISIONER] Installation complete. PVs will be stored on /data/local-path-provisioner (extra disk)."
