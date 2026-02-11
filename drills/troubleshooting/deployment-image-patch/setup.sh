#!/bin/bash
kubectl delete deploy backend-api 2>/dev/null || true
kubectl create deploy backend-api --image=nginx:1.18 --replicas=1
