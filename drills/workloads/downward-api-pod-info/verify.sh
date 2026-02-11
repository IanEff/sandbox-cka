#!/bin/bash
if ! kubectl get pod downward-pod; then exit 1; fi

POD_NAME=$(kubectl exec downward-pod -- env | grep POD_NAME=downward-pod)
POD_NS=$(kubectl exec downward-pod -- env | grep POD_NAMESPACE=default)

if [[ -z "$POD_NAME" ]] || [[ -z "$POD_NS" ]]; then
    echo "Environment variables not set correctly"
    exit 1
fi
echo "Environment variables verified"
