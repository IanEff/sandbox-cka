#!/bin/bash
kubectl delete ns rbac-drill --ignore-not-found
kubectl create ns rbac-drill
echo "Namespace rbac-drill created."
