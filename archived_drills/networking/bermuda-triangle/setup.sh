#!/bin/bash

# Cleanup
kubectl delete ns atlantic airspace --force --grace-period=0 2>/dev/null || true

kubectl create ns atlantic
kubectl create ns airspace

# Setup Tower (Target)
kubectl run control-tower -n atlantic --image=nginx --restart=Always --labels=app=tower
kubectl expose pod control-tower -n atlantic --port=80

# Setup Pilot (Source)
kubectl run pilot -n airspace --image=curlimages/curl --restart=Always --labels=flight=19 -- sleep 3600

# The Anomaly (Deny All Ingress)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: magnetic-storm
  namespace: atlantic
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

kubectl wait --for=condition=Ready pod/control-tower -n atlantic --timeout=60s
kubectl wait --for=condition=Ready pod/pilot -n airspace --timeout=60s
