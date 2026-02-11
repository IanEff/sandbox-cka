#!/bin/bash
NS="secure-app"
DEPLOY="web-app"
SECRET="app-secret"

# 1. Check Secret existence and content
if ! kubectl get secret $SECRET -n $NS > /dev/null 2>&1; then
  echo "Secret '$SECRET' does not exist."
  exit 1
fi

VAL=$(kubectl get secret $SECRET -n $NS -o jsonpath='{.data.API_KEY}' | base64 -d)
if [[ "$VAL" != "12345-secret-token" ]]; then
  echo "Secret key 'API_KEY' has value '$VAL', expected '12345-secret-token'."
  exit 1
fi

# 2. Check Pod status using wait
# We use a timeout because it might take a moment to recover after secret creation
if kubectl wait --for=condition=ready pod -l app=web -n $NS --timeout=15s > /dev/null 2>&1; then
  echo "Pods are running with the secret loaded."
  exit 0
else
  echo "Pods are not ready. Check 'kubectl get pods -n $NS'."
  exit 1
fi
