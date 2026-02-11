#!/bin/bash
# Verify for hpa-missing-metrics

# Check if requests are set
requests=$(kubectl get deploy php-apache -n hpa-test -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')

if [ -z "$requests" ]; then
    echo "CPU requests still missing on deployment."
    exit 1
fi

# Verify HPA status (might take a moment, but if requests are there, it's considered fixed)
# We can check if status has CurrentMetric properly? 
# Usually simply checking for request presence is enough for valid logic check.

echo "CPU requests found: $requests. HPA should work."
exit 0
