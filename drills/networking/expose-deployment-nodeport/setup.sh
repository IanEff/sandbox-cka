#!/bin/bash
kubectl delete svc web-service --ignore-not-found
kubectl delete deploy web-app --ignore-not-found

kubectl create deploy web-app --image=nginx --replicas=1
kubectl wait --for=condition=available deploy/web-app --timeout=30s
