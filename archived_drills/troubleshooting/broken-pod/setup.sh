#!/bin/bash
kubectl create ns dev --dry-run=client -o yaml | kubectl apply -f -
kubectl run web-frontend --image=busybox -n dev --restart=Always --dry-run=client -o yaml --command -- sl -la > /tmp/pod.yaml
kubectl apply -f /tmp/pod.yaml
