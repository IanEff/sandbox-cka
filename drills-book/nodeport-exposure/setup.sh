#!/bin/bash
mkdir -p /opt/course/overlay5
chmod 777 /opt/course/overlay5
kubectl create ns external-apps --dry-run=client -o yaml | kubectl apply -f -
