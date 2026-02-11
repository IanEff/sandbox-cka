#!/bin/bash
kubectl create ns rbac-4 --dry-run=client -o yaml | kubectl apply -f -
# Reset
kubectl delete sa pod-viewer -n rbac-4 --ignore-not-found
kubectl delete role pod-reader-role -n rbac-4 --ignore-not-found
kubectl delete rolebinding pod-reader-binding -n rbac-4 --ignore-not-found
