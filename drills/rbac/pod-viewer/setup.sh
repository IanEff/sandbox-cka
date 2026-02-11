#!/bin/bash
kubectl create ns drill-rbac --dry-run=client -o yaml | kubectl apply -f -
