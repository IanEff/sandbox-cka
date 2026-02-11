#!/bin/bash
set -e

kubectl create ns development --dry-run=client -o yaml | kubectl apply -f -
echo "Namespace 'development' created."
