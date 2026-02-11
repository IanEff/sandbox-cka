#!/bin/bash
kubectl create ns anti-affinity --dry-run=client -o yaml | kubectl apply -f -
kubectl delete deploy redis-cache -n anti-affinity --ignore-not-found
