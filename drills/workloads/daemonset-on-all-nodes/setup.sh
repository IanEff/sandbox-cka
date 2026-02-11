#!/bin/bash
kubectl delete ns ds-drill --ignore-not-found
kubectl create ns ds-drill

echo "Namespace ds-drill created."
