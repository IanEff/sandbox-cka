#!/bin/bash
set -e

# Check if the port in the HTTPRoute is 8080
kubectl get httproute web-route -o jsonpath='{.spec.rules[0].backendRefs[0].port}' | grep 8080
