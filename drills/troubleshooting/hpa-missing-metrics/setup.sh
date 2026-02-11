#!/bin/bash
# Setup for hpa-missing-metrics

kubectl delete ns hpa-test 2>/dev/null || true
kubectl create ns hpa-test

# Deployment WITHOUT requests
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
  namespace: hpa-test
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 1
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        # MISSING RESOURCES
EOF

kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10 -n hpa-test
