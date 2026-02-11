#!/bin/bash
# Setup: Create mismatching deployment and service

kubectl delete deployment updater --ignore-not-found
kubectl delete service updater-service --ignore-not-found

# Deployment with label app=updater-v1
kubectl create deployment updater --image=nginx --replicas=2
kubectl patch deployment updater -p '{"spec": {"template": {"metadata": {"labels": {"app": "updater-v1"}}}}}'

# Service selecting app=updater (mismatch)
kubectl create service clusterip updater-service --tcp=80:80

echo "Deployment 'updater' and Service 'updater-service' created with broken selector."
