#!/bin/bash
set -e

echo "[METALLB] Installing MetalLB LoadBalancer..."

export KUBECONFIG=/etc/kubernetes/admin.conf
METALLB_VERSION="v0.14.9"

# 1. Enable strict ARP mode (required for MetalLB in L2 mode)
# actually, kube-proxy strictARP is usually good practice, let's check/set it
echo "Enabling strictARP in kube-proxy..."
kubectl get configmap kube-proxy -n kube-system -o yaml | \
 sed -e "s/strictARP: false/strictARP: true/" | \
 kubectl apply -f - -n kube-system

# 2. Install MetalLB Manifests
echo "Applying MetalLB manifests (${METALLB_VERSION})..."
MANIFEST_URL="https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml"
DEST_FILE="/tmp/metallb-native.yaml"

# Robust download with cache-first and fallback to direct
# We use the apt-cacher-ng remap feature to pull through the cache if available.
DOWNLOAD_SUCCESS=0
if [ "$SANDBOX_K8S_CACHE_ENABLED" = "1" ] && [ -n "$SANDBOX_CACHE_HOST" ]; then
    # Use the Remap-githubraw proxy we defined in acng.conf
    CACHE_PROXY_URL="http://${SANDBOX_CACHE_HOST}:${SANDBOX_CACHE_APT_PORT}/githubraw.proxy/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml"
    echo "Attempting to download through cache: ${CACHE_PROXY_URL}"
    if curl -s -L -f -o ${DEST_FILE} "${CACHE_PROXY_URL}"; then
        echo "Successfully downloaded through cache."
        DOWNLOAD_SUCCESS=1
    else
        echo "Cache download failed. Falling back to direct..."
    fi
fi

if [ "$DOWNLOAD_SUCCESS" -eq 0 ]; then
    echo "Downloading MetalLB manifest from ${MANIFEST_URL}..."
    # Robust download with retries and no proxy interference
    for i in {1..5}; do
      https_proxy="" HTTPS_PROXY="" http_proxy="" HTTP_PROXY="" curl -L -f -o ${DEST_FILE} ${MANIFEST_URL} && break
      echo "Attempt $i failed. Retrying in 5s..."
      sleep 5
    done
fi

if [ ! -f "${DEST_FILE}" ]; then
  echo "ERROR: Failed to download MetalLB manifest. Skipping installation."
  exit 0
fi

kubectl apply -f ${DEST_FILE}

# 3. Configure IP Address Pool and L2 Advertisement
# Create the config file for the background job to apply
CONFIG_FILE="/tmp/metallb-config.yaml"
cat <<EOF > "${CONFIG_FILE}"
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.56.200-192.168.56.240
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF

# Run configuration in background to avoid blocking vagrant up
LOG_FILE="/var/log/metallb-provision.log"
echo "Backgrounding MetalLB configuration waiter. Logs at ${LOG_FILE}"

nohup bash -c "
  export KUBECONFIG=/etc/kubernetes/admin.conf
  
  echo 'Waiting for MetalLB controller to be ready...'
  # Increase timeout to 5m for slow pulls
  if kubectl wait --namespace metallb-system \
    --for=condition=ready pod \
    --selector=app=metallb,component=controller \
    --timeout=300s; then

    # Give the webhook service a moment to register endpoints
    sleep 10
    
    echo 'Applying MetalLB configuration...'
    kubectl apply -f ${CONFIG_FILE}
    echo 'MetalLB configured successfully.'
  else
    echo 'WARNING: MetalLB controller wait timed out.'
  fi
" > "${LOG_FILE}" 2>&1 &

echo "[METALLB] Installation procedure finished (Configuration applying in background)."
