#!/bin/bash
mkdir -p /opt/course/overlay3
chmod 777 /opt/course/overlay3
kubectl create ns app-layer --dry-run=client -o yaml | kubectl apply -f -
