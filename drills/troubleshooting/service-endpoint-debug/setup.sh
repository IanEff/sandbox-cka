#!/bin/bash
kubectl create ns troubleshooting-5 --dry-run=client -o yaml | kubectl apply -f -

# Force update Deployment to ensure it has the WRONG label even if user fixed it
# kubectl apply might merge, so we delete and recreate to be sure we reset the drill.
kubectl delete deployment frontend-dep -n troubleshooting-5 --ignore-not-found
kubectl delete service frontend-svc -n troubleshooting-5 --ignore-not-found

# Create Deployment with label app=front-end
kubectl create deployment frontend-dep --image=nginx --replicas=2 -n troubleshooting-5 --dry-run=client -o yaml | \
sed 's/app: frontend-dep/app: front-end/' | kubectl apply -f -

# Create Service with selector app=frontend (Mismatch)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: troubleshooting-5
spec:
  selector:
    app: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF
