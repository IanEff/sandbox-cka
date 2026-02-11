#!/bin/bash
set -e

# Check PV exists
if ! kubectl get pv important-data-pv &>/dev/null; then
    echo "❌ PV 'important-data-pv' not found"
    exit 1
fi

# Check reclaim policy is Retain
policy=$(kubectl get pv important-data-pv -o jsonpath='{.spec.persistentVolumeReclaimPolicy}')
if [ "$policy" != "Retain" ]; then
    echo "❌ PV reclaim policy is '$policy', expected 'Retain'"
    exit 1
fi

echo "✅ PV 'important-data-pv' now has Retain reclaim policy"
exit 0
