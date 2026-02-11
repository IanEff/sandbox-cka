#!/bin/bash
set -e

# Configuration
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH="amd64"
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH="arm64"; fi

echo "[CILIUM] Installing Cilium CLI ${CILIUM_CLI_VERSION}..."

# Download Cilium CLI
DEST_FILE="cilium-linux-${CLI_ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/${DEST_FILE}"
CACHE_DIR="/vagrant/infra/artifacts"

DOWNLOAD_SUCCESS=0

# Try Local Artifact Cache first (fastest)
if [ -f "${CACHE_DIR}/${DEST_FILE}" ]; then
    echo "Found cached Cilium CLI at ${CACHE_DIR}/${DEST_FILE}"
    cp "${CACHE_DIR}/${DEST_FILE}" "${DEST_FILE}"
    DOWNLOAD_SUCCESS=1
fi

# Try Remote Cache (if enabled)
if [ "$DOWNLOAD_SUCCESS" -eq 0 ] && [ "$SANDBOX_K8S_CACHE_ENABLED" = "1" ] && [ -n "$SANDBOX_CACHE_HOST" ]; then
    # Use the Remap-github proxy
    CACHE_PROXY_URL="http://${SANDBOX_CACHE_HOST}:${SANDBOX_CACHE_APT_PORT}/github.proxy/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/${DEST_FILE}"
    echo "Attempting to download through cache: ${CACHE_PROXY_URL}"
    if curl -s -L -f -o ${DEST_FILE} "${CACHE_PROXY_URL}"; then
        echo "Successfully downloaded through cache."
        DOWNLOAD_SUCCESS=1
    else
        echo "Cache download failed. Falling back to direct..."
    fi
fi

if [ "$DOWNLOAD_SUCCESS" -eq 0 ]; then
    echo "Downloading Cilium CLI from ${DOWNLOAD_URL}..."
    curl -L --fail --remote-name-all "${DOWNLOAD_URL}"{,.sha256sum}
    # Only check sha if we downloaded the sha file (which we only do in direct mode here for simplicity, 
    # or we could download sha via cache too, but let's keep it simple for now as the user wants direct mostly)
    sha256sum --check ${DEST_FILE}.sha256sum
    rm ${DEST_FILE}.sha256sum
    
    # Cache it for next time
    if [ -d "${CACHE_DIR}" ]; then
        echo "Caching Cilium CLI to ${CACHE_DIR}/${DEST_FILE}"
        cp "${DEST_FILE}" "${CACHE_DIR}/${DEST_FILE}"
    fi
fi

sudo tar -xzvf ${DEST_FILE} -C /usr/local/bin
rm ${DEST_FILE}

# Install Gateway API CRDs
# Note: We use v1.2.0 experimental to include TLSRoute/TCPRoute which Cilium requires
echo "[CILIUM] Installing Gateway API CRDs..."
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/experimental-install.yaml

# Install Cilium
echo "[CILIUM] Installing Cilium CNI..."
# We enable Gateway API in Cilium and kube-proxy replacement for L2/Gateway support
cilium install --wait \
  --set gatewayAPI.enabled=true \
  --set kubeProxyReplacement=true

# Enable Hubble
echo "[CILIUM] Enabling Hubble..."
cilium hubble enable --ui

echo "[CILIUM] Installation Complete."
cilium status
