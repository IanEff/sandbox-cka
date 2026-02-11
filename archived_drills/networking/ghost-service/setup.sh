#!/bin/bash
kubectl create ns haunted --dry-run=client -o yaml | kubectl apply -f -

# Cleanup existing resources
kubectl delete deploy spirit -n haunted --ignore-not-found

# Create deployment
# Label: app=spirit, type=poltergeist
kubectl create deploy spirit --image=nginx -n haunted --replicas=2
kubectl label deploy spirit -n haunted type=poltergeist
# deployment pods will have app=spirit (default from create deploy)
# But wait, kubectl create deploy spirit ... puts label app=spirit on pod template.

# Create Service with WRONG selector
# We'll set selector to app=ghost
kubectl create service clusterip phantom --tcp=80:80 -n haunted --dry-run=client -o yaml | \
  sed 's/app: phantom/app: ghost/' | \
  kubectl apply -f -
