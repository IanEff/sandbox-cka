#!/bin/bash
mkdir -p /opt/course/overlay4
chmod 777 /opt/course/overlay4
kubectl create ns finance --dry-run=client -o yaml | kubectl apply -f -
