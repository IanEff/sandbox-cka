#!/bin/bash
set -e

# Install Helm if not present
if ! command -v helm &> /dev/null; then
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
fi

# Create a chart
helm create /tmp/mychart

# Install with a bad image tag
# Use --wait=false so setup doesn't hang
helm upgrade --install broken-app /tmp/mychart \
    --set image.repository=nginx \
    --set image.tag=tag-that-does-not-exist \
    --wait=false

rm -rf /tmp/mychart
