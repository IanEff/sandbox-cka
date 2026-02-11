#!/bin/bash
kubectl create ns workloads-drill --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment web-app --image=nginx:1.24 --replicas=3 -n workloads-drill --dry-run=client -o yaml | kubectl apply -f -
kubectl wait --for=condition=available deployment/web-app -n workloads-drill --timeout=60s || true
# Trigger bad update
kubectl set image deployment/web-app nginx=nginx:1.300 -n workloads-drill
