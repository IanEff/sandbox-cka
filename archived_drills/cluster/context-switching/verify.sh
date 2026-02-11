#!/bin/bash

CURRENT_CONTEXT=$(kubectl config current-context)

if [ "$CURRENT_CONTEXT" == "restricted" ]; then
    echo "Correct context selected."
    exit 0
else
    echo "Current context is '$CURRENT_CONTEXT', expected 'restricted'."
    exit 1
fi
