#!/bin/bash
# Setup for env-from-secret

kubectl delete secret app-config --ignore-not-found
kubectl delete pod env-pod --ignore-not-found
