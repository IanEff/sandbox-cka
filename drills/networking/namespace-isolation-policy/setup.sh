#!/bin/bash
kubectl create ns project-a --dry-run=client -o yaml | kubectl apply -f -
kubectl delete netpol --all -n project-a
