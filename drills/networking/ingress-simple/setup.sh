#!/bin/bash
NS="web-exposed"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

kubectl create deploy web --image=nginx --port=80 -n $NS
kubectl expose deploy web --name=web-svc --port=80 -n $NS
