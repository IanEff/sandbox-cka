#!/bin/bash
kubectl create ns dev-team --dry-run=client -o yaml | kubectl apply -f -
