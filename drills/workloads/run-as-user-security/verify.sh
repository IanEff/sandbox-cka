#!/bin/bash
# Check running state first
if ! kubectl wait --for=condition=ready pod/secure-pod --timeout=5s 2>/dev/null; then
    # If not ready, check if it's at least scheduled/pending. 
    # But usually a security context mismatch might prevent startup if PSP/Validation fails, 
    # though CKA 1.30+ doesn't have PSP by default.
    # If it's crashing, we might still want to check config.
    echo "Pod secure-pod is not ready."
fi

UID_VAL=$(kubectl get pod secure-pod -o jsonpath='{.spec.securityContext.runAsUser}')
GID_VAL=$(kubectl get pod secure-pod -o jsonpath='{.spec.securityContext.runAsGroup}')

# Also check container level if spec level is missing, or vice versa
if [[ -z "$UID_VAL" ]]; then
    UID_VAL=$(kubectl get pod secure-pod -o jsonpath='{.spec.containers[0].securityContext.runAsUser}')
fi
if [[ -z "$GID_VAL" ]]; then
    GID_VAL=$(kubectl get pod secure-pod -o jsonpath='{.spec.containers[0].securityContext.runAsGroup}')
fi

if [[ "$UID_VAL" != "1001" ]]; then echo "Wrong UID: $UID_VAL"; exit 1; fi
if [[ "$GID_VAL" != "3000" ]]; then echo "Wrong GID: $GID_VAL"; exit 1; fi
