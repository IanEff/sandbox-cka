#!/bin/bash
kubectl delete ns trouble --ignore-not-found
kubectl create ns trouble
kubectl run lost-log --image=nginx:1.27 -n trouble
kubectl wait --for=condition=ready pod lost-log -n trouble
