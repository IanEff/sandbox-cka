#!/bin/bash
NS="quota-land"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Apply ResourceQuota
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: $NS
spec:
  hard:
    requests.cpu: "500m"
    requests.memory: 1Gi
    pods: "5"
EOF

# Create Deployment requesting too much CPU (1 > 500m)
# Note: Deployment creation succeeds, but Pod creation will be blocked by Quota Admission Controller
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bloated-app
  namespace: $NS
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bloated
  template:
    metadata:
      labels:
        app: bloated
    spec:
      containers:
      - name: pause
        image: k8s.gcr.io/pause:3.2
        resources:
          requests:
            cpu: "1"
            memory: "128Mi"
EOF
