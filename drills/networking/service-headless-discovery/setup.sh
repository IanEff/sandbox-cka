#!/bin/bash
# Setup for service-headless-discovery

kubectl delete svc db-headless --ignore-not-found
kubectl delete deploy backend-db --ignore-not-found
