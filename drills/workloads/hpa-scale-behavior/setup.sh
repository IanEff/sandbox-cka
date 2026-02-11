#!/bin/bash
kubectl create ns hpa-behavior --dry-run=client -o yaml | kubectl apply -f -
# Clean up if exists
kubectl delete hpa php-apache -n hpa-behavior --ignore-not-found
kubectl delete deploy php-apache -n hpa-behavior --ignore-not-found
kubectl delete svc php-apache -n hpa-behavior --ignore-not-found
