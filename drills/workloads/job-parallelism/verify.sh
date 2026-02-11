#!/bin/bash
set -e

# Verify Job exists
if ! kubectl get job batch-processor > /dev/null 2>&1; then
    echo "FAIL: Job 'batch-processor' not found."
    exit 1
fi

# Verify Parallelism and Completions
PARALLELISM=$(kubectl get job batch-processor -o jsonpath='{.spec.parallelism}')
COMPLETIONS=$(kubectl get job batch-processor -o jsonpath='{.spec.completions}')

if [ "$PARALLELISM" != "5" ]; then
    echo "FAIL: Job parallelism is not 5. Found: $PARALLELISM"
    exit 1
fi

if [ "$COMPLETIONS" != "10" ]; then
    echo "FAIL: Job completions is not 10. Found: $COMPLETIONS"
    exit 1
fi

# Wait for Job to complete
echo "Waiting for Job to complete..."
kubectl wait --for=condition=complete job/batch-processor --timeout=60s > /dev/null

echo "SUCCESS: Job configured correctly and completed."
