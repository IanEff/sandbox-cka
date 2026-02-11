#!/bin/bash
# Setup: Create foo-service and bar-service

kubectl delete deployment foo-dep bar-dep --ignore-not-found
kubectl delete service foo-service bar-service ingress example-ingress --ignore-not-found

# Foo App
kubectl create deployment foo-dep --image=hashicorp/http-echo --port=5678 -- --text="foo"
kubectl expose deployment foo-dep --name=foo-service --port=8080 --target-port=5678

# Bar App
kubectl create deployment bar-dep --image=hashicorp/http-echo --port=5678 -- --text="bar"
kubectl expose deployment bar-dep --name=bar-service --port=9090 --target-port=5678

echo "Services foo-service and bar-service created."
