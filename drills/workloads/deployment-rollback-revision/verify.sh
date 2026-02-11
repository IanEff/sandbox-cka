#!/bin/bash
# Verify for deployment-rollback-revision

NS="rollout-test"
DEP="nginx-deploy"

# 1. Check Current Image (Should be 1.21)
IMG=$(kubectl -n $NS get deploy $DEP -o jsonpath='{.spec.template.spec.containers[0].image}')
if [ "$IMG" != "nginx:1.21" ]; then
    echo "FAIL: Current image is $IMG, expected nginx:1.21 (did you rollback?)"
    exit 1
fi

# 2. Check Revisions (Should be > 1 to prove change happened)
# This is tricky without parsing "rollout history" text.
# Alternative: Check generation. If we created, updated, and updated back, generation should be at least 3.
# 1 (Create) -> 2 (Update to 1.22) -> 3 (Rollback/Update to 1.21)
GEN=$(kubectl -n $NS get deploy $DEP -o jsonpath='{.metadata.generation}')
if [ "$GEN" -lt 3 ]; then
    echo "FAIL: Generation is $GEN (expected >= 3). Did you perform the update and rollback steps?"
    exit 1
fi

echo "SUCCESS: Rollback successful."
