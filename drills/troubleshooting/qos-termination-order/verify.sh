#!/bin/bash
# Verify QoS Termination Order Drill
set -e

NS="project-omega"
RESULT_FILE="/home/vagrant/pods-terminated-first.txt"

# Check result file exists
if [[ ! -f "$RESULT_FILE" ]]; then
    echo "FAIL: Result file $RESULT_FILE not found"
    exit 1
fi

# Get actual BestEffort pods
# Use awk to trim whitespace and grep to remove empty lines
EXPECTED=$(kubectl get pods -n $NS -o jsonpath='{range .items[?(@.status.qosClass=="BestEffort")]}{.metadata.name}{"\n"}{end}' | awk '{$1=$1};1' | sort | grep .)

# Read user's answer
ACTUAL=$(cat "$RESULT_FILE" | tr -d '\r' | awk '{$1=$1};1' | sort | grep .)

# Compare
if [[ "$EXPECTED" != "$ACTUAL" ]]; then
    echo "FAIL: Pod list incorrect"
    echo "Expected (BestEffort pods):"
    echo "$EXPECTED"
    echo ""
    echo "Got:"
    echo "$ACTUAL"
    exit 1
fi

# Verify correct count
EXPECTED_COUNT=$(echo "$EXPECTED" | grep -c . || echo 0)
ACTUAL_COUNT=$(cat "$RESULT_FILE" | grep -c . || echo 0)

if [[ "$EXPECTED_COUNT" != "$ACTUAL_COUNT" ]]; then
    echo "FAIL: Expected $EXPECTED_COUNT pods, found $ACTUAL_COUNT"
    exit 1
fi

echo "SUCCESS: Correctly identified BestEffort pods that would be terminated first"
echo "Pods: $EXPECTED"
