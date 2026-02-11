#!/bin/bash
# Verify Event Log Forensics Drill
set -e

ERRORS=0

# 1. Check cluster-events.sh
SCRIPT="/home/vagrant/cluster-events.sh"
if [ ! -f "$SCRIPT" ]; then
    echo "FAIL: $SCRIPT not found"
    ERRORS=$((ERRORS + 1))
else
    # Verify the script contains the right components
    CONTENT=$(cat "$SCRIPT")
    if ! echo "$CONTENT" | grep -q "kubectl"; then
        echo "FAIL: $SCRIPT doesn't contain a kubectl command"
        ERRORS=$((ERRORS + 1))
    elif ! echo "$CONTENT" | grep -q "\-\-sort-by\|sort-by"; then
        echo "FAIL: $SCRIPT doesn't use --sort-by"
        ERRORS=$((ERRORS + 1))
    elif ! echo "$CONTENT" | grep -qi "creationTimestamp"; then
        echo "FAIL: $SCRIPT doesn't sort by creationTimestamp"
        ERRORS=$((ERRORS + 1))
    elif ! echo "$CONTENT" | grep -q "\-A\|--all-namespaces"; then
        echo "FAIL: $SCRIPT doesn't query all namespaces"
        ERRORS=$((ERRORS + 1))
    else
        # Test execution
        chmod +x "$SCRIPT"
        if timeout 10 bash "$SCRIPT" >/dev/null 2>&1; then
            echo "PASS: cluster-events.sh is valid and executable"
        else
            echo "FAIL: cluster-events.sh failed to execute"
            ERRORS=$((ERRORS + 1))
        fi
    fi
fi

# 2. Check pod lifecycle events log
LOG="/home/vagrant/pod-lifecycle-events.log"
if [ ! -f "$LOG" ]; then
    echo "FAIL: $LOG not found"
    ERRORS=$((ERRORS + 1))
else
    # Should contain events related to pod scheduling/pulling/started/killing
    if grep -qi "Scheduled\|Pulled\|Created\|Started\|Killing\|SuccessfulCreate" "$LOG"; then
        echo "PASS: pod-lifecycle-events.log contains lifecycle events"
    else
        echo "FAIL: pod-lifecycle-events.log doesn't appear to contain pod lifecycle events"
        echo "  (Expected keywords like Scheduled, Pulled, Created, Started, Killing)"
        ERRORS=$((ERRORS + 1))
    fi
fi

# 3. Check restart policy
POLICY_FILE="/home/vagrant/restart-policy.txt"
if [ ! -f "$POLICY_FILE" ]; then
    echo "FAIL: $POLICY_FILE not found"
    ERRORS=$((ERRORS + 1))
else
    POLICY=$(cat "$POLICY_FILE" | tr -d '[:space:]')
    if [ "$POLICY" = "Always" ]; then
        echo "PASS: Restart policy correctly identified as 'Always'"
    else
        echo "FAIL: Expected restart policy 'Always', got '$POLICY'"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Verify deployment is still healthy
if ! kubectl wait --for=condition=available deployment/web-app -n forensics-lab --timeout=30s >/dev/null 2>&1; then
    echo "FAIL: web-app deployment is not available (should still have 2 running pods)"
    ERRORS=$((ERRORS + 1))
else
    echo "PASS: web-app deployment is healthy"
fi

echo ""
if [ $ERRORS -gt 0 ]; then
    echo "FAIL: $ERRORS error(s) found"
    exit 1
fi

echo "SUCCESS: Event and log forensics completed correctly"
