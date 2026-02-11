#!/bin/bash
kubectl create ns restrict-ns --dry-run=client -o yaml | kubectl apply -f -
