#!/bin/bash
set -e

# Create namespace
kubectl create ns netpol-demo --dry-run=client -o yaml | kubectl apply -f -

# Ensure clean slate
kubectl delete pod backend -n netpol-demo --ignore-not-found
kubectl delete netpol allow-metrics-only -n netpol-demo --ignore-not-found

# Create the backend pod with named port
kubectl run backend --image=nginx:alpine --labels=app=backend --port=80 -n netpol-demo --overrides='
{
  "spec": {
    "containers": [
      {
        "name": "backend",
        "image": "nginx:alpine",
        "ports": [
          {
            "name": "http-metrics",
            "containerPort": 80
          }
        ]
      }
    ]
  }
}'
