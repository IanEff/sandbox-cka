#!/bin/bash

# Check Deployment requests
if ! kubectl get deployment php-apache -n scaling &>/dev/null; then
  echo "ERROR: Deployment php-apache not found"
  exit 1
fi

REQUESTS=$(kubectl get deployment php-apache -n scaling -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
if [[ "$REQUESTS" != "200m" ]]; then
  echo "ERROR: CPU requests are $REQUESTS, expected 200m"
  exit 1
fi

# Check HPA
if ! kubectl get hpa php-apache -n scaling &>/dev/null; then
  echo "ERROR: HPA php-apache not found"
  exit 1
fi

MIN=$(kubectl get hpa php-apache -n scaling -o jsonpath='{.spec.minReplicas}')
MAX=$(kubectl get hpa php-apache -n scaling -o jsonpath='{.spec.maxReplicas}')
TARGET=$(kubectl get hpa php-apache -n scaling -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}')

# Note: HPA v1 vs v2 structure might differ in jsonpath inspection slightly depending on cluster version
# Fallback check for v1 style targetCPUUtilizationPercentage if metrics field is complex
if [[ -z "$TARGET" ]]; then
    TARGET=$(kubectl get hpa php-apache -n scaling -o jsonpath='{.spec.targetCPUUtilizationPercentage}')
fi

if [[ "$MIN" -ne 1 ]]; then
  echo "ERROR: Min replicas is $MIN, expected 1"
  exit 1
fi

if [[ "$MAX" -ne 10 ]]; then
  echo "ERROR: Max replicas is $MAX, expected 10"
  exit 1
fi

if [[ "$TARGET" -ne 50 ]]; then
  echo "ERROR: Target CPU utilization is $TARGET, expected 50"
  exit 1
fi

echo "SUCCESS: HPA configured correctly"
exit 0
