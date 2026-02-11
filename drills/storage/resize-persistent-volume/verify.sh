#!/bin/bash
SIZE=$(kubectl get pvc resize-me-pvc -o jsonpath='{.spec.resources.requests.storage}')
if [[ "$SIZE" == "100Mi" ]]; then
    exit 0
else
    echo "PVC size is $SIZE, expected 100Mi"
    exit 1
fi
