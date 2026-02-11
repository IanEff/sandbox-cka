#!/bin/bash
NS="ingress-test"
ING="main-ingress"

# Check existence
if ! kubectl get ingress $ING -n $NS > /dev/null 2>&1; then
  echo "FAIL: Ingress $ING not found"
  exit 1
fi

# Check Host
HOST=$(kubectl get ingress $ING -n $NS -o jsonpath='{.spec.rules[0].host}')
if [[ "$HOST" != "my-app.com" ]]; then
  echo "FAIL: Host is $HOST, expected my-app.com"
  exit 1
fi

# Check Paths using jsonpath
PATH1=$(kubectl get ingress $ING -n $NS -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/alpha")].backend.service.name}')
PATH2=$(kubectl get ingress $ING -n $NS -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/beta")].backend.service.name}')

if [[ "$PATH1" != "svc-alpha" ]]; then echo "FAIL: /alpha routes to $PATH1"; exit 1; fi
if [[ "$PATH2" != "svc-beta" ]]; then echo "FAIL: /beta routes to $PATH2"; exit 1; fi

echo "SUCCESS: Ingress configured correctly"
exit 0
