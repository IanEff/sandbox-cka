#!/bin/bash
kubectl create ns history-limit --dry-run=client -o yaml | kubectl apply -f -
kubectl delete deploy clean-history -n history-limit --ignore-not-found
