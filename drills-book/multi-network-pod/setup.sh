#!/bin/bash
mkdir -p /opt/course/overlay7
chmod 777 /opt/course/overlay7
kubectl create ns database --dry-run=client -o yaml | kubectl apply -f -
