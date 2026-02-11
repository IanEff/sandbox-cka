#!/bin/bash
NS="trouble-cm"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Create incomplete CM
kubectl create configmap app-config --from-literal=other-key=value -n $NS

# Create Pod referencing missing key
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: $NS
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'echo "Connecting to \$DB_URL"; sleep 3600']
    env:
    - name: DB_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: db-url
EOF
