#!/bin/bash
NS="debug-svc"
# Cleanup for idempotency
kubectl delete ns $NS --ignore-not-found=true --wait=true

kubectl create ns $NS

# Deployment (Label: app=frontend)
kubectl create deploy frontend --image=nginx:alpine --replicas=3 -n $NS

# Broken Service (Selector: app=front-end) - Typo
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: $NS
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: front-end
EOF
