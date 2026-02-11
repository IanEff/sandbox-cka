#!/bin/bash
# Setup for automount-sa-token

kubectl delete sa secure-bot --ignore-not-found
kubectl delete pod paranoid-pod --ignore-not-found
