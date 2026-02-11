#!/bin/bash
# Setup: Create Gateway API resources

# Create GatewayClass (if not exists)
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy-gateway
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
EOF

# Create Gateway
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: default
spec:
  gatewayClassName: envoy-gateway
  listeners:
  - name: http
    protocol: HTTP
    port: 80
EOF

# Create deployments and services for v1 and v2
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v1
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
      version: v1
  template:
    metadata:
      labels:
        app: myapp
        version: v1
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:1.0
        args:
        - "-text=Version 1"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: app-v1
  namespace: default
spec:
  selector:
    app: myapp
    version: v1
  ports:
  - port: 8080
    targetPort: 5678
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v2
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
      version: v2
  template:
    metadata:
      labels:
        app: myapp
        version: v2
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:1.0
        args:
        - "-text=Version 2"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: app-v2
  namespace: default
spec:
  selector:
    app: myapp
    version: v2
  ports:
  - port: 8080
    targetPort: 5678
EOF

echo "Created Gateway and services for v1 and v2"
exit 0
