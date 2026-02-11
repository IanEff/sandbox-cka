#!/bin/bash
# Verify for netpol-dual-selector

NS="restricted-net"
NP="secure-access"

# 1. Check existence
if ! kubectl -n $NS get netpol $NP >/dev/null 2>&1; then
    echo "FAIL: NetworkPolicy $NP not found in namespace $NS"
    exit 1
fi

# 2. Check Pod Selector (app=sensitive)
SELECTOR=$(kubectl -n $NS get netpol $NP -o jsonpath='{.spec.podSelector.matchLabels.app}')
if [ "$SELECTOR" != "sensitive" ]; then
    echo "FAIL: expected podSelector app=sensitive, got $SELECTOR"
    exit 1
fi

# 3. Check Ingress Rules
# We need to look for two distinct items in the 'from' list if they implemented it as "OR".
# OR valid implementation: One rule with two 'from' entries, OR two rules each with one 'from'.
# Actually, standard way for OR is multiple 'from' elements in one 'ingress' item, OR multiple 'ingress' items.
# Standard way for AND (Same NS + Labels) is one 'from' element with 'podSelector'.

# Let's inspect the JSON to be robust.
JSON=$(kubectl -n $NS get netpol $NP -o json)

# Check for local namespace pod selector (role=admin AND access=full)
# This corresponds to a 'from' entry with ONLY 'podSelector' (implicitly same namespace)
has_local_and=$(echo "$JSON" | jq '.spec.ingress[].from[] | select(.podSelector.matchLabels.role=="admin" and .podSelector.matchLabels.access=="full" and .namespaceSelector==null)')

if [ -z "$has_local_and" ]; then
    echo "FAIL: Did not find rule for Pods in same namespace with role=admin AND access=full"
    exit 1
fi

# Check for monitoring namespace selector
# This corresponds to a 'from' entry with 'namespaceSelector' matching monitoring
has_monitoring=$(echo "$JSON" | jq '.spec.ingress[].from[] | select(.namespaceSelector.matchLabels."kubernetes.io/metadata.name"=="monitoring")')
# Note: user might use a label on the namespace. We didn't specify a label for the monitoring namespace, 
# so they rely on the automatic label 'kubernetes.io/metadata.name' or they might assume they need to label it.
# Let's support the 'name' label convention or just check if it selects the namespace by name if they used that.
# Actually, CKA usually implies 'kubernetes.io/metadata.name' for "namespace named X".
# Or they used a matchLabels that matches a label they think is there.
# Let's check generally for a namespaceSelector that selects 'monitoring'.
# Simplest check: did they use matchLabels on the name?
has_monitoring_by_name=$(echo "$JSON" | jq '.spec.ingress[].from[] | select(.namespaceSelector.matchLabels."kubernetes.io/metadata.name"=="monitoring")')

if [ -z "$has_monitoring_by_name" ]; then
    # Maybe they labelled the namespace? We didn't ask them to label it, so they SHOULD use the automatic label.
    # But let's check if they created a selector that assumes a label "name=monitoring" or similar.
    echo "FAIL: Did not find rule for namespace 'monitoring' (did you use kubernetes.io/metadata.name string?)"
    exit 1
fi

echo "SUCCESS: NetworkPolicy $NP configured correctly."
