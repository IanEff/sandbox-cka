#!/bin/bash
# Verify Multi-Container Log Debug Drill
set -e

NS="debug-lab"
POD="data-pipeline"
ERRORS=0

# 1. Check failing container identification
FAIL_FILE="/home/vagrant/failing-container.txt"
if [ ! -f "$FAIL_FILE" ]; then
    echo "FAIL: $FAIL_FILE not found"
    ERRORS=$((ERRORS + 1))
else
    ANSWER=$(cat "$FAIL_FILE" | tr -d '[:space:]')
    if [ "$ANSWER" = "processor" ]; then
        echo "PASS: Correctly identified 'processor' as the failing container"
    else
        echo "FAIL: Expected 'processor', got '$ANSWER'"
        ERRORS=$((ERRORS + 1))
    fi
fi

# 2. Check crash error message
ERR_FILE="/home/vagrant/crash-error.txt"
if [ ! -f "$ERR_FILE" ]; then
    echo "FAIL: $ERR_FILE not found"
    ERRORS=$((ERRORS + 1))
else
    ERR_MSG=$(cat "$ERR_FILE" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if echo "$ERR_MSG" | grep -q "config file /etc/pipeline/config.yaml not found"; then
        echo "PASS: Error message correctly captured"
    else
        echo "FAIL: Error should contain 'config file /etc/pipeline/config.yaml not found'"
        echo "  Got: '$ERR_MSG'"
        ERRORS=$((ERRORS + 1))
    fi
fi

# 3. Check pod is now fully running with all 3 containers
if ! kubectl get pod $POD -n $NS >/dev/null 2>&1; then
    echo "FAIL: Pod '$POD' not found in namespace $NS"
    ERRORS=$((ERRORS + 1))
else
    # Verify all 3 expected containers exist
    CONTAINERS=$(kubectl get pod $POD -n $NS -o jsonpath='{.spec.containers[*].name}')
    for EXPECTED in fetcher processor exporter; do
        if ! echo "$CONTAINERS" | grep -q "$EXPECTED"; then
            echo "FAIL: Container '$EXPECTED' not found in pod"
            ERRORS=$((ERRORS + 1))
        fi
    done

    # Check all containers ready
    READY_COUNT=0
    for CNAME in $(kubectl get pod $POD -n $NS -o jsonpath='{.spec.containers[*].name}'); do
        IS_READY=$(kubectl get pod $POD -n $NS -o jsonpath="{.status.containerStatuses[?(@.name==\"$CNAME\")].ready}")
        if [ "$IS_READY" = "true" ]; then
            READY_COUNT=$((READY_COUNT + 1))
        fi
    done

    if [ "$READY_COUNT" -eq 3 ]; then
        echo "PASS: All 3 containers are running and ready (3/3)"
    else
        echo "FAIL: Expected 3/3 containers ready, got $READY_COUNT/3"
        kubectl get pod $POD -n $NS
        ERRORS=$((ERRORS + 1))
    fi
fi

echo ""
if [ $ERRORS -gt 0 ]; then
    echo "FAIL: $ERRORS error(s) found"
    exit 1
fi

echo "SUCCESS: Multi-container log investigation completed correctly"
