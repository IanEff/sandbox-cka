#!/bin/bash
kubectl create ns ingress-test --dry-run=client -o yaml | kubectl apply -f -

# Create Services and backends
kubectl create deployment app-alpha --image=nginx -n ingress-test
kubectl create service clusterip svc-alpha --tcp=80:80 -n ingress-test

kubectl create deployment app-beta --image=nginx -n ingress-test
kubectl create service clusterip svc-beta --tcp=80:80 -n ingress-test
