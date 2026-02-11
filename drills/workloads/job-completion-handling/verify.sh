#!/bin/bash
# Verify for job-completion-handling

NS="job-specialist"
JOB="batch-processor"

# 1. Check Job exists
if ! kubectl -n $NS get job $JOB >/dev/null 2>&1; then
    echo "FAIL: Job $JOB not found in namespace $NS"
    exit 1
fi

# 2. Check completions
COMPLETIONS=$(kubectl -n $NS get job $JOB -o jsonpath='{.spec.completions}')
if [ "$COMPLETIONS" != "5" ]; then
    echo "FAIL: expected completions=5, got $COMPLETIONS"
    exit 1
fi

# 3. Check parallelism
PARALLELISM=$(kubectl -n $NS get job $JOB -o jsonpath='{.spec.parallelism}')
if [ "$PARALLELISM" != "2" ]; then
    echo "FAIL: expected parallelism=2, got $PARALLELISM"
    exit 1
fi

# 4. Check ttlSecondsAfterFinished
TTL=$(kubectl -n $NS get job $JOB -o jsonpath='{.spec.ttlSecondsAfterFinished}')
if [ "$TTL" != "30" ]; then
    echo "FAIL: expected ttlSecondsAfterFinished=30, got $TTL"
    exit 1
fi

echo "SUCCESS: Job $JOB configured correctly."
