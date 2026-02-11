#!/bin/bash

FILE="/opt/course/1/nodes.txt"

if [ ! -f "$FILE" ]; then
    echo "FAIL: File $FILE does not exist."
    exit 1
fi

# Generate expected output
EXPECTED=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}' | sort)

# Read user output
USER_OUTPUT=$(cat "$FILE")

# Normalize whitespace for comparison
DIFF=$(diff <(echo "$EXPECTED") <(echo "$USER_OUTPUT"))

if [ ! -z "$DIFF" ]; then
    echo "FAIL: Content mismatch."
    echo "Expected:"
    echo "$EXPECTED"
    echo "Found:"
    echo "$USER_OUTPUT"
    exit 1
fi

echo "SUCCESS: File content matches node list."
