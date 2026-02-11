#!/bin/bash
DIR="/opt/course/overlay8"
NS="full-stack"

if [ ! -f "$DIR/traffic-flow.txt" ]; then echo "Missing traffic-flow.txt"; exit 1; fi
# Optional strictly
# if [ ! -f "$DIR/packet-capture.txt" ]; then echo "Missing packet-capture.txt"; exit 1; fi

kubectl get deploy api-server -n $NS > /dev/null 2>&1 || { echo "Deploy missing"; exit 1; }
kubectl get svc api-svc -n $NS > /dev/null 2>&1 || { echo "Service missing"; exit 1; }
kubectl get ingress api-ingress -n $NS > /dev/null 2>&1 || { echo "Ingress missing"; exit 1; }

exit 0
