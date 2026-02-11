#!/bin/bash

# Wait for Ready
echo "Waiting for web-frontend to be ready..."
if kubectl wait --for=condition=ready pod -l app=web-frontend -n drill-crash --timeout=20s; then
    echo "Pod is Ready!"
    exit 0
else
    echo "Pod failed to become ready."
    exit 1
fi
