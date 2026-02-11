#!/bin/bash
# cluster/static-pod-manifest/setup.sh
# Nothing really to setup, just ensure clean slate
MANIFEST_PATH="/etc/kubernetes/manifests/static-web.yaml"

if [ -f "$MANIFEST_PATH" ]; then
    echo "Cleaning up existing manifest at $MANIFEST_PATH"
    sudo rm -f "$MANIFEST_PATH" 2>/dev/null || rm -f "$MANIFEST_PATH"
fi

echo "Setup complete: Ready for static pod creation."
