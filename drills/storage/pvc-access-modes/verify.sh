#!/bin/bash
set -euo pipefail

KUBECTL_TIMEOUT_SECONDS=10
K="timeout ${KUBECTL_TIMEOUT_SECONDS} kubectl"

# Check PVC exists
if ! $K get pvc shared-data -n default &>/dev/null; then
    echo "❌ PVC 'shared-data' not found in default namespace"
    exit 1
fi

# Check PVC is bound
status=$($K get pvc shared-data -n default -o jsonpath='{.status.phase}')
if [ "$status" != "Bound" ]; then
    echo "❌ PVC is not Bound (status: $status)"
    exit 1
fi

# Check access mode is ReadWriteOnce (local-path supports only RWO)
access_modes=$($K get pvc shared-data -n default -o jsonpath='{.spec.accessModes[*]}')
if [[ ! "$access_modes" =~ (^|[[:space:]])ReadWriteOnce($|[[:space:]]) ]]; then
    echo "❌ PVC does not have ReadWriteOnce access mode (found: $access_modes)"
    exit 1
fi

# Check storage request
storage=$($K get pvc shared-data -n default -o jsonpath='{.spec.resources.requests.storage}')
if [ "$storage" != "2Gi" ]; then
    echo "❌ PVC storage request is $storage, expected 2Gi"
    exit 1
fi

# Check storage class
sc=$($K get pvc shared-data -n default -o jsonpath='{.spec.storageClassName}')
if [ "$sc" != "local-path" ]; then
    echo "❌ PVC storage class is $sc, expected local-path"
    exit 1
fi

echo "✅ PVC 'shared-data' is correctly configured for local-path (ReadWriteOnce)"
exit 0
