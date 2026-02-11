#!/bin/bash
set -e

# Configuration
WEAVE_VERSION="v2.8.1"
MANIFEST_URL="https://github.com/weaveworks/weave/releases/download/${WEAVE_VERSION}/weave-daemonset-k8s.yaml"
DEST_FILE="/tmp/weave.yaml"

echo "[WEAVENET] Installing Weave Net CNI ${WEAVE_VERSION}..."

# Download Manifest
echo "[WEAVENET] Downloading manifest..."
curl -L -o ${DEST_FILE} "${MANIFEST_URL}"

# Configure IPALLOC_RANGE
# We need to set the IPALLOC_RANGE to match our Pod CIDR (10.244.0.0/16)
# Default Weave is usually 10.32.0.0/12
echo "[WEAVENET] Configuring IPALLOC_RANGE to 10.244.0.0/16..."

# We inject the env var into the weave container
# Pattern match for the container definition and insert the env var
sed -i '/name: weave$/a \              - name: IPALLOC_RANGE\n                value: "10.244.0.0/16"' ${DEST_FILE}

# Apply
echo "[WEAVENET] Applying manifest..."
kubectl apply -f ${DEST_FILE}

echo "[WEAVENET] Installation Complete."
rm ${DEST_FILE}
