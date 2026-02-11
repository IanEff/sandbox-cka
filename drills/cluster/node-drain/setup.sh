#!/bin/bash
kubectl uncordon ubukubu-node-1 2>/dev/null || true
kubectl create ns cluster-ops --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment web-server --image=nginx --replicas=6 -n cluster-ops --dry-run=client -o yaml | kubectl apply -f -
kubectl wait --for=condition=available deployment/web-server -n cluster-ops --timeout=60s
