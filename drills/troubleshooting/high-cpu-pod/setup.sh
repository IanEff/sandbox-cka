#!/bin/bash
# Setup for high-cpu-pod

kubectl delete ns cpu-burn 2>/dev/null || true
kubectl create ns cpu-burn

# Low usage
kubectl run nginx-1 --image=nginx:alpine -n cpu-burn
kubectl run nginx-2 --image=nginx:alpine -n cpu-burn

# High usage (busy loop)
# python -c "while True: pass" is good enough
kubectl run stress-cpu --image=python:alpine -n cpu-burn --command -- python -c "while True: pass"

# Wait for them to be running
kubectl wait --for=condition=ready pod --all -n cpu-burn --timeout=60s
