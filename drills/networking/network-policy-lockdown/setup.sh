#!/bin/bash
set -e

NS="project-snake"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Clean up previous run
kubectl delete pod backend db1 db2 vault -n $NS --ignore-not-found --force --grace-period=0

# Create generic backend (client)
kubectl run backend --image=curlimages/curl -n $NS --labels="app=backend" -- sleep infinity

# Create DB1 (Listening on 1111)
kubectl run db1 --image=busybox -n $NS --labels="app=db1" --restart=Never -- sh -c 'while true; do nc -lk -p 1111 -e echo "Hello from DB1"; done'

# Create DB2 (Listening on 2222)
kubectl run db2 --image=busybox -n $NS --labels="app=db2" --restart=Never -- sh -c 'while true; do nc -lk -p 2222 -e echo "Hello from DB2"; done'

# Create Rogue DB (Listening on 3333, shouldn't be reachable)
kubectl run vault --image=busybox -n $NS --labels="app=vault" --restart=Never -- sh -c 'while true; do nc -lk -p 3333 -e echo "Secret Vault"; done'

# Wait for pods
kubectl wait --for=condition=ready pod --all -n $NS --timeout=60s
