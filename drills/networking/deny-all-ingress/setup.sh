#!/bin/bash
kubectl create ns secure-net --dry-run=client -o yaml | kubectl apply -f -
# Clean up potential leftovers
kubectl delete pod backend -n secure-net --force --grace-period=0 2>/dev/null
kubectl delete pod intruder --force --grace-period=0 2>/dev/null
kubectl delete netpol default-deny -n secure-net 2>/dev/null

kubectl run backend --image=nginx --port=80 -n secure-net
kubectl run intruder --image=busybox --restart=Never -- sleep 3600

kubectl wait --for=condition=ready pod/backend -n secure-net --timeout=60s
kubectl wait --for=condition=ready pod/intruder --timeout=60s
