#!/bin/bash
NS="reports"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -
