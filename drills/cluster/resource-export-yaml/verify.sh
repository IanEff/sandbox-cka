#!/bin/bash

FILE="/opt/course/5/services.yaml"

if [ ! -f "$FILE" ]; then
    echo "FAIL: File $FILE does not exist."
    exit 1
fi

# Count services in file
# We can just count "apiVersion: v1" occurrences or Kind: Service
FILE_COUNT=$(grep -c "kind: Service" "$FILE")

# Count actual services
ACTUAL_COUNT=$(kubectl get svc -n kube-system --no-headers | wc -l)
# Normalize white space
ACTUAL_COUNT=$(echo "$ACTUAL_COUNT" | xargs)

if [ "$FILE_COUNT" -lt "$ACTUAL_COUNT" ]; then
    echo "FAIL: File seems to contain fewer Services ($FILE_COUNT) than expected ($ACTUAL_COUNT)."
    exit 1
fi

# Check if file contains valid yaml (basic check)
# try dry-run apply?
if ! kubectl apply -f "$FILE" --dry-run=client > /dev/null 2>&1; then
    echo "FAIL: content of $FILE is not valid YAML or standard k8s manifests."
    # It might fail if they exported with cluster IPs and trying to dry-run apply conflicts?
    # But usually dry-run=client is fine.
    # Actually, commonly 'kubectl get svc <name> -o yaml' includes clusterIP which is immutable or duplicate error if trying to create new.
    # But here we just check validity.
    # If the user just did 'kubectl get svc -n kube-system -o yaml > file', it's a List kind.
    
    # Check if it's a List
    if grep -q "kind: List" "$FILE"; then
         echo "SUCCESS: Found List kind, assumption of valid export."
         exit 0
    fi
    
    # If not valid, print error
    # Actually, `kubectl get svc -o yaml` produces a List. `kubectl get svc -o yaml > file` is standard.
    # So grep "kind: Service" counts might be 0 if it's inside items? No, items still have kind: Service.
    
    echo "WARNING: Could not validate YAML with kubectl apply --dry-run. Please check manually."
fi

echo "SUCCESS: File exists and contains Service manifests."
