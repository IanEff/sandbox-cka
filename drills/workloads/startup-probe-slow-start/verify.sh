#!/bin/bash
# Verify for startup-probe-slow-start

NS="legacy"
DEP="legacy-app"

# 1. Check Startup Probe existence
PROBE=$(kubectl -n $NS get deployment $DEP -o jsonpath='{.spec.template.spec.containers[0].startupProbe}')

if [ -z "$PROBE" ]; then
    echo "FAIL: No startupProbe configured."
    exit 1
fi

# 2. Check total startup time allowance
# Total time = failureThreshold * periodSeconds
FT=$(kubectl -n $NS get deployment $DEP -o jsonpath='{.spec.template.spec.containers[0].startupProbe.failureThreshold}')
PS=$(kubectl -n $NS get deployment $DEP -o jsonpath='{.spec.template.spec.containers[0].startupProbe.periodSeconds}')

# Defaults if not set (though user should set them to meet 60s req)
FT=${FT:-3}
PS=${PS:-10}

TOTAL=$((FT * PS))

if [ "$TOTAL" -lt 60 ]; then
    echo "FAIL: Startup probe total duration is ${TOTAL}s (threshold $FT * period $PS), expected >= 60s."
    exit 1
fi

echo "SUCCESS: Startup Probe configured correctly."
