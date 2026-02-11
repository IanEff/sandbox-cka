#!/bin/bash
mkdir -p /opt/course/overlay2
chmod 777 /opt/course/overlay2
kubectl create ns net-lab --dry-run=client -o yaml | kubectl apply -f -
