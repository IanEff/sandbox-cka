#!/bin/bash
DIR="/opt/course/overlay4"

if [ ! -f "$DIR/service-ip.txt" ]; then echo "Missing service-ip.txt"; exit 1; fi
if [ ! -f "$DIR/explanation.txt" ]; then echo "Missing explanation.txt"; exit 1; fi

kubectl get deploy payment-api -n finance > /dev/null 2>&1 || { echo "Deploy missing"; exit 1; }
kubectl get svc payment-svc -n finance > /dev/null 2>&1 || { echo "Service missing"; exit 1; }

exit 0
