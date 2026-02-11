#!/bin/bash
# Setup for Gateway User-Agent Routing Drill
set -e

# Cleanup
kubectl delete ns project-mobile --ignore-not-found=true --wait=true

# Create namespace
kubectl create ns project-mobile

# Create backend deployments
kubectl create deployment mobile-backend --image=nginx:alpine -n project-mobile
kubectl create deployment desktop-backend --image=nginx:alpine -n project-mobile

# Expose services
kubectl expose deployment mobile-backend --port=80 -n project-mobile
kubectl expose deployment desktop-backend --port=80 -n project-mobile

# Wait for pods
kubectl wait --for=condition=available deployment/mobile-backend -n project-mobile --timeout=60s
kubectl wait --for=condition=available deployment/desktop-backend -n project-mobile --timeout=60s

# Customize nginx responses to identify which backend served the request
kubectl exec -n project-mobile deployment/mobile-backend -- sh -c 'echo "MOBILE BACKEND" > /usr/share/nginx/html/app'
kubectl exec -n project-mobile deployment/desktop-backend -- sh -c 'echo "DESKTOP BACKEND" > /usr/share/nginx/html/app'

# Create Gateway using Envoy Gateway (Convoy)
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: project-mobile
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: Same
EOF

echo "Setup complete."
echo "Create HTTPRoute 'ua-router' to route based on User-Agent header"
echo "Gateway available at NodePort or LoadBalancer IP"
