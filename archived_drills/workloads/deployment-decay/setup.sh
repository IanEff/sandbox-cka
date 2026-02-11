#!/bin/bash
kubectl create ns lifecycle --dry-run=client -o yaml | kubectl apply -f -

# Create a deployment that fails readiness check
# Nginx listens on 80 by default. we will configure readiness probe to check 8080.
# The user needs to either change app to listen on 8080 (harder with nginx image) OR fix probe to 80.
# The problem says "Developers insist app listens on 8080", implying maybe the app IS configured to 8080?
# Actually, let's make it a mismatch. App listens on 80, probe checks 8080.
# But checking 8080 would fail with connection refused.
# Let's make it more interesting.
# Let's just use nginx (port 80) and probe 8080.
# To make it tricky, maybe we name the container port 8080 but it's actually 80? No that's too confusing.
# Simple mismatch is best for CKA level.

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-frontend
  namespace: lifecycle
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
        image: nginx:alpine
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
EOF
