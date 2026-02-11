#!/bin/bash
# Setup for service-loadbalancer-metallb

kubectl delete svc lb-service --ignore-not-found
kubectl delete deploy lb-app --ignore-not-found
