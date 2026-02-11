#!/bin/bash
DIR="/opt/course/overlay3"

if [ ! -f "$DIR/service-ips.txt" ]; then echo "Missing service-ips.txt"; exit 1; fi
if [ ! -f "$DIR/nameserver.txt" ]; then echo "Missing nameserver.txt"; exit 1; fi

kubectl get deploy web-backend -n app-layer > /dev/null 2>&1 || { echo "Deploy missing"; exit 1; }
kubectl get svc web-backend-svc -n app-layer > /dev/null 2>&1 || { echo "Service missing"; exit 1; }
kubectl get pod dns-detective -n app-layer > /dev/null 2>&1 || { echo "dns-detective missing"; exit 1; }
kubectl get pod dns-detective-2 -n default > /dev/null 2>&1 || { echo "dns-detective-2 missing"; exit 1; }

exit 0
