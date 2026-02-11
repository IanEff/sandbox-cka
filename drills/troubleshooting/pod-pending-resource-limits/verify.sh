#!/bin/bash
kubectl wait --for=condition=ready pod/huge-pod --timeout=5s
