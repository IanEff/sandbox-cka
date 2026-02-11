#!/bin/bash
kubectl create ns restricted 2>/dev/null || true
kubectl run test-pod --image=nginx:alpine -n restricted --restart=Never 2>/dev/null || true
kubectl delete netpol --all -n restricted 2>/dev/null || true
echo "Setup complete. Namespace 'restricted' created."
