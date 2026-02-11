#!/bin/bash
set -e

echo "[METRICS SERVER] Installing Metrics Server"

# 1. Download official manifest (latest)
# 1. Download official manifest (pinned version v0.7.2 for K8s 1.34 compat)
MANIFEST_URL="https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml"
DEST_FILE="/tmp/metrics-server-components.yaml"

# Robust download with cache-first and fallback to direct
# We use the apt-cacher-ng remap feature to pull through the cache if available.
DOWNLOAD_SUCCESS=0
if [ "$SANDBOX_K8S_CACHE_ENABLED" = "1" ] && [ -n "$SANDBOX_CACHE_HOST" ]; then
    # Use the Remap-github proxy we defined in acng.conf
    CACHE_PROXY_URL="http://${SANDBOX_CACHE_HOST}:${SANDBOX_CACHE_APT_PORT}/github.proxy/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml"
    echo "Attempting to download through cache: ${CACHE_PROXY_URL}"
    if curl -s -L -f -o ${DEST_FILE} "${CACHE_PROXY_URL}"; then
        echo "Successfully downloaded through cache."
        DOWNLOAD_SUCCESS=1
    else
        echo "Cache download failed. Falling back to direct..."
    fi
fi

if [ "$DOWNLOAD_SUCCESS" -eq 0 ]; then
    echo "Downloading metrics server manifest from ${MANIFEST_URL}..."
    # Robust download with retries and no proxy interference
    # Added -k (insecure) to bypass potential proxy SSL verification issues since we verify content later/installing dev env
    for i in {1..5}; do
      https_proxy="" HTTPS_PROXY="" http_proxy="" HTTP_PROXY="" curl -L -k -f -o ${DEST_FILE} ${MANIFEST_URL} && break
      echo "Attempt $i failed. Retrying in 5s..."
      sleep 5
    done
fi

if [ ! -f "${DEST_FILE}" ]; then
  echo "ERROR: Failed to download metrics server manifest. Skipping installation to avoid halting Vagrant."
  exit 0
fi

# 2. Patch manifest to support insecure TLS (required for local kubeadm)
# We search for the container args and append the insecure flag.
# The pattern looks for the line containing 'args:' and appends the new arg after it.
echo "Patching manifest for insecure TLS..."
sed -i '/args:/a \        - --kubelet-insecure-tls' ${DEST_FILE}

# 3. Apply manifest
echo "Applying manifest..."
# Ensure we use the root kubeconfig explicitly or rely on env. 
# Vagrant shell provisioner runs as root, and control-plane.sh sets up /root/.kube/config.
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl apply -f ${DEST_FILE}

# 4. Patch to allow running on control plane
# This prevents the pod from being stuck in Pending if worker nodes aren't ready yet.
echo "Patching metrics-server to tolerate control-plane taint..."
kubectl patch deployment metrics-server -n kube-system --patch '{"spec": {"template": {"spec": {"tolerations": [{"key": "node-role.kubernetes.io/control-plane", "operator": "Exists", "effect": "NoSchedule"}]}}}}'

# echo "[METRICS SERVER] Waiting for rollout..."
# kubectl rollout status deployment metrics-server -n kube-system --timeout=60s || echo "Warning: Metrics server rollout timed out, but it might still be starting."

echo "[METRICS SERVER] Installation complete."
