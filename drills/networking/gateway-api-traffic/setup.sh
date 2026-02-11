#!/bin/bash
set -e

# Create namespace
kubectl create ns project-r500 --dry-run=client -o yaml | kubectl apply -f -

# Create backend services
kubectl run desktop --image=nginx --port=80 -n project-r500 --expose
kubectl run mobile --image=httpd --port=80 -n project-r500 --expose

# Create Gateway (using standard Convoy installation)
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: project-gateway
  namespace: project-r500
spec:
  gatewayClassName: convoy
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: Same
EOF

# Create the old ingress for reference (dummy, just to confuse/guide)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: legacy-ingress
  namespace: project-r500
spec:
  rules:
  - http:
      paths:
      - path: /desktop
        pathType: Prefix
        backend:
          service:
            name: desktop
            port:
              number: 80
      - path: /mobile
        pathType: Prefix
        backend:
          service:
            name: mobile
            port:
              number: 80
EOF
