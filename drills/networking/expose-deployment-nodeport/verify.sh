#!/bin/bash
PORT=$(kubectl get svc web-service -o jsonpath='{.spec.ports[0].nodePort}')
TYPE=$(kubectl get svc web-service -o jsonpath='{.spec.type}')

if [[ "$TYPE" == "NodePort" ]] && [[ "$PORT" == "30080" ]]; then
    exit 0
else
    echo "Service is $TYPE on port $PORT (expected NodePort 30080)"
    exit 1
fi
