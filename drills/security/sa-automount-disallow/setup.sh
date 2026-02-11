#!/bin/bash
# Setup
kubectl delete sa secure-sa --ignore-not-found
kubectl delete pod secure-pod --ignore-not-found
