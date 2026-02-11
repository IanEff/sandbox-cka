#!/bin/bash
NS="web-apps"
ING="web-router"

kubectl get ingress $ING -n $NS > /dev/null 2>&1 || { echo "Ingress missing"; exit 1; }
kubectl get deploy blog -n $NS > /dev/null 2>&1 || { echo "Deploy blog missing"; exit 1; }
kubectl get deploy shop -n $NS > /dev/null 2>&1 || { echo "Deploy shop missing"; exit 1; }
kubectl get deploy docs -n $NS > /dev/null 2>&1 || { echo "Deploy docs missing"; exit 1; }

# Basic rule check
HOST1=$(kubectl get ingress $ING -n $NS -o jsonpath='{.spec.rules[*].host}' | grep blog.example.com)
HOST2=$(kubectl get ingress $ING -n $NS -o jsonpath='{.spec.rules[*].host}' | grep shop.example.com)

if [ -z "$HOST1" ]; then echo "Missing blog host"; exit 1; fi
if [ -z "$HOST2" ]; then echo "Missing shop host"; exit 1; fi

exit 0
