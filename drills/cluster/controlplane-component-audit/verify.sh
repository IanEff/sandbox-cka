#!/bin/bash
# Verify Controlplane Component Audit Drill
set -e

RESULT_FILE="/home/vagrant/controlplane-components.txt"

if [ ! -f "$RESULT_FILE" ]; then
    echo "FAIL: $RESULT_FILE not found"
    exit 1
fi

ERRORS=0

check_line() {
    local component="$1"
    local expected="$2"
    local line
    line=$(grep -i "^${component}:" "$RESULT_FILE" | head -1 | sed 's/^[^:]*: *//')

    if [ -z "$line" ]; then
        echo "FAIL: No entry found for '$component'"
        ERRORS=$((ERRORS + 1))
        return
    fi

    # Normalize whitespace
    line=$(echo "$line" | tr -s ' ' | sed 's/^ *//;s/ *$//')
    local expected_norm
    expected_norm=$(echo "$expected" | tr -s ' ' | sed 's/^ *//;s/ *$//')

    if [ "$line" != "$expected_norm" ]; then
        echo "FAIL: $component: expected '$expected_norm', got '$line'"
        ERRORS=$((ERRORS + 1))
    else
        echo "PASS: $component: $line"
    fi
}

# kubelet runs as a systemd process
check_line "kubelet" "process"

# kube-apiserver, kube-scheduler, kube-controller-manager, etcd are static pods
check_line "kube-apiserver" "static-pod"
check_line "kube-scheduler" "static-pod"
check_line "kube-controller-manager" "static-pod"
check_line "etcd" "static-pod"

# DNS is coredns, deployed as a regular pod (Deployment)
DNS_LINE=$(grep -i "^dns:" "$RESULT_FILE" | head -1 | sed 's/^[^:]*: *//' | tr -s ' ' | sed 's/^ *//;s/ *$//')
if echo "$DNS_LINE" | grep -qi "pod.*coredns"; then
    echo "PASS: dns: $DNS_LINE"
elif [ "$DNS_LINE" = "pod coredns" ] || [ "$DNS_LINE" = "pod CoreDNS" ]; then
    echo "PASS: dns: $DNS_LINE"
else
    echo "FAIL: dns: expected 'pod coredns', got '$DNS_LINE'"
    ERRORS=$((ERRORS + 1))
fi

echo ""
if [ $ERRORS -gt 0 ]; then
    echo "FAIL: $ERRORS error(s) found"
    exit 1
fi

echo "SUCCESS: All controlplane components correctly identified"
