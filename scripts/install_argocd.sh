#!/bin/bash
set -e

# Load common environment if needed, but mostly we rely on standard tools
# source /vagrant/scripts/common.sh

echo "[ARGOCD] Installing ArgoCD..."

MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
DEST_FILE="/tmp/argocd-install.yaml"

# Robust download with retries
for i in {1..5}; do
  https_proxy="" HTTPS_PROXY="" http_proxy="" HTTP_PROXY="" curl -L -k -f -o ${DEST_FILE} ${MANIFEST_URL} && break
  echo "Attempt $i failed. Retrying in 5s..."
  sleep 5
done

if [ ! -f "${DEST_FILE}" ]; then
  echo "ERROR: Failed to download ArgoCD manifest."
  exit 1
fi

export KUBECONFIG=/etc/kubernetes/admin.conf

# Create namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Apply manifest
echo "[ARGOCD] Applying manifest..."
kubectl apply -n argocd -f ${DEST_FILE}

# Wait for ArgoCD Server deployment to be created so we can patch it
echo "[ARGOCD] Waiting for argocd-server deployment..."
# Wait loop for creation
for i in {1..30}; do
  kubectl get deployment argocd-server -n argocd >/dev/null 2>&1 && break
  sleep 2
done

# Patch for Insecure Mode (disable internal TLS, serve HTTP)
echo "[ARGOCD] Patching for insecure mode..."
kubectl -n argocd patch deployment argocd-server --type=json \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--insecure"}]' 2>/dev/null || \
kubectl -n argocd patch deployment argocd-server --type=json \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["--insecure"]}]'

# Expose ArgoCD
# Strategy: Ingress (Nginx) -> Gateway API (Envoy/Cilium) -> LoadBalancer (MetalLB) -> NodePort

if kubectl get ingressclass nginx >/dev/null 2>&1; then
  echo "[ARGOCD] IngressClass 'nginx' detected. Creating Ingress..."
  cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
    nginx.ingress.kubernetes.io/ssl-passthrough: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.ubukubu
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              name: http
EOF

elif kubectl get gatewayclass >/dev/null 2>&1; then
  echo "[ARGOCD] GatewayClass detected. Creating Gateway API resources..."
  # Detect GatewayClass (prefer 'eg', then 'cilium', then fallback to first available)
  if kubectl get gatewayclass eg >/dev/null 2>&1; then
      GW_CLASS="eg"
  elif kubectl get gatewayclass cilium >/dev/null 2>&1; then
      GW_CLASS="cilium"
  else
      GW_CLASS=$(kubectl get gatewayclass -o jsonpath='{.items[0].metadata.name}')
  fi
  echo "Using GatewayClass: $GW_CLASS"

  cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: argocd-gateway
  namespace: argocd
spec:
  gatewayClassName: $GW_CLASS
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: argocd-route
  namespace: argocd
spec:
  parentRefs:
  - name: argocd-gateway
  # hostnames:
  # - "argocd.ubukubu"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: argocd-server
      port: 80
EOF

else
  echo "[ARGOCD] No Ingress or Gateway detected. Checking for MetalLB..."
  if kubectl get ns metallb-system >/dev/null 2>&1; then
    echo "[ARGOCD] MetalLB detected. Patching Service to LoadBalancer..."
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
  else
    echo "[ARGOCD] No LoadBalancer detected. Patching Service to NodePort..."
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
  fi
fi

echo "[ARGOCD] Installation complete. Rollout happening in background."
echo "Initial Admin Password (check later if failed):"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo || echo "(Secret not yet available)"
echo ""

