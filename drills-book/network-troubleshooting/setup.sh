#!/bin/bash
mkdir -p /opt/course/overlay8
chmod 777 /opt/course/overlay8
NS="broken-app"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Backend deployment
kubectl create deploy backend --image=nginx --replicas=2 -n $NS
kubectl label deploy backend app=backend -n $NS --overwrite

# Frontend deployment
kubectl create deploy frontend --image=curlimages/curl --replicas=1 -n $NS -- sleep 3600
# using curlimages/curl for reliable curl availability


# Broken Service (selects wrong app)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: $NS
spec:
  selector:
    app: backend-wrong
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF
