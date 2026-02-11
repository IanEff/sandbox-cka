#!/bin/bash
kubectl delete deploy nginx-deploy 2>/dev/null || true
kubectl delete svc static-port 2>/dev/null || true
kubectl create deploy nginx-deploy --image=nginx:alpine --replicas=1
