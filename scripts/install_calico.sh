#!/bin/bash
set -e

# Configuration
CALICO_VERSION="v3.27.0"
MANIFEST_URL="https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/calico.yaml"
DEST_FILE="/tmp/calico.yaml"

echo "[CALICO] Installing Calico CNI ${CALICO_VERSION}..."

# Download Manifest
if [ "$SANDBOX_K8S_CACHE_ENABLED" = "1" ] && [ -n "$SANDBOX_CACHE_HOST" ]; then
    # CACHE_PROXY_URL="http://${SANDBOX_CACHE_HOST}:${SANDBOX_CACHE_APT_PORT}/k8s.proxy/projectcalico/calico/${CALICO_VERSION}/manifests/calico.yaml"
    # Actually, raw.githubusercontent.com is hard to proxy directly with apt-cacher-ng regarding path structure sometimes.
    # Let's stick to direct download for the manifest itself as it's small.
    # But we can try to use a GH proxy if available.
    echo "[CALICO] Downloading manifest (direct)..."
    curl -L -o ${DEST_FILE} "${MANIFEST_URL}"
else
    echo "[CALICO] Downloading manifest..."
    curl -L -o ${DEST_FILE} "${MANIFEST_URL}"
fi

# Configure Pod CIDR
# The default sandbox Pod CIDR is 10.244.0.0/16.
# Calico default is 192.168.0.0/16.
echo "[CALICO] Configuring Pod CIDR to 10.244.0.0/16..."

# Uncomment CALICO_IPV4POOL_CIDR and set value
sed -i 's|# - name: CALICO_IPV4POOL_CIDR|- name: CALICO_IPV4POOL_CIDR|' ${DEST_FILE}
sed -i 's|#   value: "192.168.0.0/16"|  value: "10.244.0.0/16"|' ${DEST_FILE}

# Apply
echo "[CALICO] Applying manifest..."
kubectl apply -f ${DEST_FILE}

echo "[CALICO] Installation Complete."
rm ${DEST_FILE}
