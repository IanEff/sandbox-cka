#!/bin/bash
kubectl delete cronjob cleanup 2>/dev/null || true
