#!/bin/bash
kubectl create ns workloads-8 --dry-run=client -o yaml | kubectl apply -f -
# Reset the Drill
kubectl delete ds cluster-monitor -n workloads-8 --ignore-not-found
