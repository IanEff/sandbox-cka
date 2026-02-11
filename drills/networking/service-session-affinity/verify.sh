#!/bin/bash
# Verify for service-session-affinity

NS="sticky-session"
SVC="backend-svc"

# 1. Check Service Affinity Type
TYPE=$(kubectl -n $NS get svc $SVC -o jsonpath='{.spec.sessionAffinity}')
if [ "$TYPE" != "ClientIP" ]; then
    echo "FAIL: Service sessionAffinity is '$TYPE', expected 'ClientIP'"
    exit 1
fi

# 2. Check Affinity Timeout
TIMEOUT=$(kubectl -n $NS get svc $SVC -o jsonpath='{.spec.sessionAffinityConfig.clientIP.timeoutSeconds}')
if [ "$TIMEOUT" != "10800" ]; then
    echo "FAIL: Service sessionAffinity timeout is '$TIMEOUT', expected '10800'"
    exit 1
fi

echo "SUCCESS: Service configured correctly."
