#!/bin/bash
kubectl delete pvc manual-pvc --force 2>/dev/null || true
kubectl delete pv manual-pv --force 2>/dev/null || true
