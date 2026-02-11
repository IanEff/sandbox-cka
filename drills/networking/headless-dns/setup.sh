#!/bin/bash
kubectl create ns headless --dry-run=client -o yaml | kubectl apply -f -
kubectl delete svc goku -n headless --ignore-not-found
kubectl delete deploy goku -n headless --ignore-not-found
