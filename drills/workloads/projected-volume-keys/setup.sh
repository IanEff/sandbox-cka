#!/bin/bash
# Setup for projected-volume-keys

kubectl delete ns projection-lab 2>/dev/null || true
kubectl create ns projection-lab
