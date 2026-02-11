#!/bin/bash

# 1. Check if pod is running
if ! kubectl get pod secure-pod > /dev/null 2>&1; then
    echo "FAIL: Pod 'secure-pod' not found."
    exit 1
fi

# 2. Check runAsUser in Spec
RUN_AS_USER=$(kubectl get pod secure-pod -o jsonpath='{.spec.securityContext.runAsUser}')
if [ "$RUN_AS_USER" != "1000" ]; then
    # Fallback: check container security context
    RUN_AS_USER_CONTAINER=$(kubectl get pod secure-pod -o jsonpath='{.spec.containers[0].securityContext.runAsUser}')
    if [ "$RUN_AS_USER_CONTAINER" != "1000" ]; then
        echo "FAIL: runAsUser is not 1000 (Pod: $RUN_AS_USER, Container: $RUN_AS_USER_CONTAINER)"
        exit 1
    fi
fi

# 3. Check fsGroup
FS_GROUP=$(kubectl get pod secure-pod -o jsonpath='{.spec.securityContext.fsGroup}')
if [ "$FS_GROUP" != "2000" ]; then
    echo "FAIL: fsGroup is not 2000 (found '$FS_GROUP')"
    exit 1
fi

# 4. Check the output file
FILE="/opt/course/2/id.txt"
if [ ! -f "$FILE" ]; then
    echo "FAIL: File $FILE does not exist. Did you write the output of 'id' there?"
    exit 1
fi

CONTENT=$(cat "$FILE")
if [[ "$CONTENT" != *"uid=1000"* ]]; then
    echo "FAIL: File content does not contain uid=1000. Found: $CONTENT"
    exit 1
fi
if [[ "$CONTENT" != *"gid=2000"* && "$CONTENT" != *"groups=2000"* ]]; then
    # fsGroup usually appears in groups=..., not necessarily gid=... depending on primary group
    # But usually fsGroup adds to supplementary groups.
    # Busybox 'id' output: uid=1000 gid=0(root) groups=2000
    if [[ "$CONTENT" != *"2000"* ]]; then
        echo "FAIL: File content does not contain group 2000. Found: $CONTENT"
        exit 1
    fi
fi

echo "SUCCESS: Pod security context configured and verified correctly."
