#!/bin/bash
# Setup for Kustomize HPA Overlay Drill
set -e

# Cleanup
kubectl delete ns web-staging --ignore-not-found=true --wait=true
kubectl delete ns web-prod --ignore-not-found=true --wait=true
rm -rf /home/vagrant/kustomize-drill

# Create namespaces
kubectl create ns web-staging
kubectl create ns web-prod

# Create base directory structure
mkdir -p /home/vagrant/kustomize-drill/base

# Base kustomization.yaml (includes legacy scaling-config)
cat > /home/vagrant/kustomize-drill/base/kustomization.yaml <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml
  - scaling-config.yaml
EOF

# Base deployment (references the legacy ConfigMap via envFrom)
cat > /home/vagrant/kustomize-drill/base/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-frontend
  template:
    metadata:
      labels:
        app: web-frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1-alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 128Mi
        envFrom:
        - configMapRef:
            name: scaling-config
EOF

# Base service
cat > /home/vagrant/kustomize-drill/base/service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: web-frontend
spec:
  selector:
    app: web-frontend
  ports:
  - port: 80
    targetPort: 80
EOF

# Legacy ConfigMap (to be removed)
cat > /home/vagrant/kustomize-drill/base/scaling-config.yaml <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: scaling-config
data:
  MIN_REPLICAS: "2"
  MAX_REPLICAS: "10"
  TARGET_CPU: "50"
EOF

echo "Setup complete."
echo "Kustomize base created at /home/vagrant/kustomize-drill/base/"
echo "Remove the legacy ConfigMap, create staging/prod overlays with HPA, and apply both."
