#!/bin/bash
set -e

# Test connection (nc -z -w 3 host port)
kubectl exec -n public-frontend web -- nc -z -w 3 db-service.secure-backend 6379
