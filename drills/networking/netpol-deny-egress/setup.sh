#!/bin/bash
# Setup for netpol-deny-egress

kubectl create namespace secure-egress --dry-run=client -o yaml | kubectl apply -f -
kubectl -n secure-egress delete netpol deny-all-egress --ignore-not-found
