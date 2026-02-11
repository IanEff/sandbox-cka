#!/bin/bash

# Check HTTPRoute exists
kubectl get httproute echo-route -n networking-6 || exit 1

# Check if Accepted
# We use a broad grep because the jsonpath might be complex depending on how many parents exist.
# But checking for type="Accepted" and status="True" is the standard.
CONDITION=$(kubectl get httproute echo-route -n networking-6 -o jsonpath='{.status.parents[*].conditions[?(@.type=="Accepted")].status}')

if [[ "$CONDITION" != *"True"* ]]; then
  echo "FAIL: HTTPRoute is not Accepted. Status: $CONDITION"
  kubectl get httproute echo-route -n networking-6 -o yaml
  exit 1
fi

# Ideally verify the path match /v1/echo specifically
PATH_MATCH=$(kubectl get httproute echo-route -n networking-6 -o jsonpath='{.spec.rules[*].matches[*].path.value}')
if [[ "$PATH_MATCH" != *"/v1/echo"* ]]; then
   echo "FAIL: Route does not match /v1/echo. Found: $PATH_MATCH"
   exit 1
fi

echo "SUCCESS: HTTPRoute is Accepted and matches /v1/echo"
exit 0
