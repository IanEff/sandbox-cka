#!/bin/bash
PORT=$(kubectl get svc static-port -o jsonpath='{.spec.ports[0].nodePort}')
if [[ "$PORT" != "30080" ]]; then echo "Wrong NodePort: $PORT"; exit 1; fi
kubectl get svc static-port
