#!/bin/bash
NS="web-exposed"
ING="web-ingress"

# Check existence
kubectl get ingress $ING -n $NS > /dev/null 2>&1 || exit 1

# Check Rules
HOST=$(kubectl get ingress $ING -n $NS -o jsonpath='{.spec.rules[0].host}')
PATH_Val=$(kubectl get ingress $ING -n $NS -o jsonpath='{.spec.rules[0].http.paths[0].path}')
SVC=$(kubectl get ingress $ING -n $NS -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')

if [ "$HOST" != "shop.example.com" ]; then echo "Wrong host: $HOST"; exit 1; fi
if [ "$PATH_Val" != "/checkout" ]; then echo "Wrong path: $PATH_Val"; exit 1; fi
if [ "$SVC" != "web-svc" ]; then echo "Wrong backend: $SVC"; exit 1; fi

echo "Verification success"
exit 0
