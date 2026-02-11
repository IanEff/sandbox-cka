#!/bin/bash
kubectl wait --for=condition=ready pod/cmd-pod --timeout=5s
