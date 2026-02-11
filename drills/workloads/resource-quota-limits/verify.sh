#!/bin/bash
set -e

# Check ResourceQuota exists
if ! kubectl get resourcequota team-quota -n team-blue &>/dev/null; then
    echo "❌ ResourceQuota 'team-quota' not found in team-blue namespace"
    exit 1
fi

# Check pod quota
pod_quota=$(kubectl get resourcequota team-quota -n team-blue -o jsonpath='{.spec.hard.pods}')
if [ "$pod_quota" != "5" ]; then
    echo "❌ Pod quota is '$pod_quota', expected '5'"
    exit 1
fi

# Check CPU quota
cpu_quota=$(kubectl get resourcequota team-quota -n team-blue -o jsonpath='{.spec.hard.requests\.cpu}')
if [ -z "$cpu_quota" ]; then
    cpu_quota=$(kubectl get resourcequota team-quota -n team-blue -o jsonpath='{.spec.hard.cpu}')
fi
if [ "$cpu_quota" != "2" ] && [ "$cpu_quota" != "2000m" ]; then
    echo "❌ CPU requests quota is '$cpu_quota', expected '2' or '2000m'"
    exit 1
fi

# Check memory quota
mem_quota=$(kubectl get resourcequota team-quota -n team-blue -o jsonpath='{.spec.hard.requests\.memory}')
if [ -z "$mem_quota" ]; then
    mem_quota=$(kubectl get resourcequota team-quota -n team-blue -o jsonpath='{.spec.hard.memory}')
fi
if [ "$mem_quota" != "4Gi" ]; then
    echo "❌ Memory requests quota is '$mem_quota', expected '4Gi'"
    exit 1
fi

# Check PVC quota
pvc_quota=$(kubectl get resourcequota team-quota -n team-blue -o jsonpath='{.spec.hard.persistentvolumeclaims}')
if [ "$pvc_quota" != "2" ]; then
    echo "❌ PVC quota is '$pvc_quota', expected '2'"
    exit 1
fi

# Check LimitRange exists
if ! kubectl get limitrange default-limits -n team-blue &>/dev/null; then
    echo "❌ LimitRange 'default-limits' not found in team-blue namespace"
    exit 1
fi

# Check default CPU limit
cpu_limit=$(kubectl get limitrange default-limits -n team-blue -o jsonpath='{.spec.limits[0].default.cpu}')
if [ "$cpu_limit" != "500m" ]; then
    echo "❌ Default CPU limit is '$cpu_limit', expected '500m'"
    exit 1
fi

# Check default memory limit
mem_limit=$(kubectl get limitrange default-limits -n team-blue -o jsonpath='{.spec.limits[0].default.memory}')
if [ "$mem_limit" != "512Mi" ]; then
    echo "❌ Default memory limit is '$mem_limit', expected '512Mi'"
    exit 1
fi

# Check default CPU request
cpu_request=$(kubectl get limitrange default-limits -n team-blue -o jsonpath='{.spec.limits[0].defaultRequest.cpu}')
if [ "$cpu_request" != "100m" ]; then
    echo "❌ Default CPU request is '$cpu_request', expected '100m'"
    exit 1
fi

# Check default memory request
mem_request=$(kubectl get limitrange default-limits -n team-blue -o jsonpath='{.spec.limits[0].defaultRequest.memory}')
if [ "$mem_request" != "128Mi" ]; then
    echo "❌ Default memory request is '$mem_request', expected '128Mi'"
    exit 1
fi

echo "✅ ResourceQuota and LimitRange configured correctly"
exit 0
