#!/bin/bash
mkdir -p /opt/course/overlay6
chmod 777 /opt/course/overlay6
kubectl create ns web-apps --dry-run=client -o yaml | kubectl apply -f -
