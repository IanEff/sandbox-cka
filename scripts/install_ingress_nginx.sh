#!/bin/bash
set -e

echo "[INGRESS-NGINX] Installing Ingress NGINX Controller..."

# Version v1.12.0
VERSION="v1.12.0"
# We use the 'cloud' provider manifest which creates a Service type=LoadBalancer.
# This works beautifully with MetalLB. If MetalLB is missing, we patch it to NodePort.
MANIFEST_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-${VERSION}/deploy/static/provider/cloud/deploy.yaml"
DEST_FILE="/tmp/ingress-nginx.yaml"

DOWNLOAD_SUCCESS=0
if [ "$SANDBOX_K8S_CACHE_ENABLED" = "1" ] && [ -n "$SANDBOX_CACHE_HOST" ]; then
    # Use the Remap-githubraw proxy
    CACHE_PROXY_URL="http://${SANDBOX_CACHE_HOST}:${SANDBOX_CACHE_APT_PORT}/githubraw.proxy/kubernetes/ingress-nginx/controller-${VERSION}/deploy/static/provider/cloud/deploy.yaml"
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

echo "Applying Ingress NGINX manifest..."
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "${DEST_FILE}"

# Check for MetalLB or LoadBalancer support
echo "Checking environment for LoadBalancer support..."
# Simple check: do we have MetalLB installed?
if kubectl get ns metallb-system &> /dev/null; then
  echo "MetalLB detected. Ingress Service type: LoadBalancer (Default)"
else
  # Check if we are in a state where a LoadBalancer works?
  # The service defaults to LoadBalancer in this manifest.
  # If we don't have MetalLB, it will hang in Pending.
  # Let's patch it to NodePort if MetalLB is clearly missing.

  # Give it a moment to see if the user perhaps installs MetalLB in parallel (unlikely in sequence)
  # But we can look at the service status? No, too early.
  
  # For now, if the metallb namespace is missing, we Force NodePort.
  if ! kubectl get ns metallb-system &>/dev/null; then
    echo "MetalLB NOT detected. Patching Ingress Service to NodePort..."
    kubectl patch svc ingress-nginx-controller -n ingress-nginx --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "NodePort"}]'
  fi
fi

echo "[INGRESS-NGINX] Installation triggered."
echo "Use 'kubectl get pods -n ingress-nginx' to verify status."
echo "Use 'kubectl get svc -n ingress-nginx' to see external IP (LoadBalancer) or Ports (NodePort)."
