#!/bin/bash
kubectl delete svc external-db 2>/dev/null || true
