#!/bin/bash
# Verify for high-cpu-pod

FILE="$HOME/high-cpu-pod.txt"

if [ ! -f "$FILE" ]; then
    echo "File $FILE not found."
    exit 1
fi

CONTENT=$(cat $FILE | tr -d '[:space:]')

if [ "$CONTENT" == "stress-cpu" ]; then
    echo "Correct pod identified."
    exit 0
else
    echo "Incorrect pod. Found: $CONTENT, Expected: stress-cpu"
    exit 1
fi
