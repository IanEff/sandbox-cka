#!/bin/bash
# Setup for pod-image-pull-error

kubectl delete pod typo-pod --ignore-not-found
# Create the broken pod
kubectl run typo-pod --image=nginxx:alpine --restart=Never
