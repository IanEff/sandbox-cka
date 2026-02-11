#!/bin/bash
mkdir -p /opt/course/overlay8
chmod 777 /opt/course/overlay8
kubectl create ns full-stack --dry-run=client -o yaml | kubectl apply -f -
