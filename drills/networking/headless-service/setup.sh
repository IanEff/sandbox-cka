#!/bin/bash
# Setup: Create namespace and StatefulSet

kubectl create namespace data --dry-run=client -o yaml | kubectl apply -f - &>/dev/null

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
  namespace: data
spec:
  serviceName: database
  replicas: 3
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: db
        image: busybox:1.36
        command: ['sh', '-c', 'sleep 3600']
        ports:
        - containerPort: 3306
          name: mysql
---
apiVersion: v1
kind: Service
metadata:
  name: database
  namespace: data
spec:
  type: ClusterIP
  selector:
    app: database
  ports:
  - port: 3306
    targetPort: 3306
EOF

# Wait for StatefulSet to be ready
kubectl wait --for=jsonpath='{.status.readyReplicas}'=3 --timeout=60s statefulset/database -n data &>/dev/null || true

echo "Created StatefulSet with regular ClusterIP service"
exit 0
