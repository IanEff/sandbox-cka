#!/bin/bash

# 1. Check if SC exists
if ! kubectl get sc high-iops > /dev/null 2>&1; then
    echo "FAIL: StorageClass 'high-iops' not found."
    exit 1
fi

# 2. Check if it is default
IS_DEFAULT=$(kubectl get sc high-iops -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')
if [ "$IS_DEFAULT" != "true" ]; then
    echo "FAIL: StorageClass 'high-iops' is not marked as default (annotation is '$IS_DEFAULT')"
    exit 1
fi

# 3. Check that no other class is default (optional sanity check, though k8s usually allows multiple if you force it, behavior is undefined)
# We won't be too strict here, but typically you should unset the old one.
# Let's check if 'standard' or 'local-path' is ALSO default.
OTHER_DEFAULTS=$(kubectl get sc -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' | grep "true" | grep -v "high-iops")

if [ ! -z "$OTHER_DEFAULTS" ]; then
    echo "WARNING: Found other default storage classes: $OTHER_DEFAULTS. You should probably unset them."
    # We can decide to fail or pass with warning. Let's pass with warning for now as strict requirement wasn't 'ensure no OTHER default exists' but 'Configure THIS to be default'.
    # Actually problem said "Ensure that any previous default StorageClass is no longer marked as default". So we SHOULD fail.
    echo "FAIL: Previous default storage classes were not unset: $OTHER_DEFAULTS"
    exit 1
fi

echo "SUCCESS: high-iops is the sole default StorageClass."
