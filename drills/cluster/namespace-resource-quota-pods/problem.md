# ResourceQuota Pods

**Drill Goal:** Limit the number of Pods in a namespace.

## Problem

1.  Create a namespace named `quota-test`.
2.  Create a ResourceQuota named `pod-limiter` in that namespace.
3.  Set the hard limit for **pods** to **2**.
4.  Demonstrate (by trying to create pods) that the limit works.  (The verification script will check the object).

## Validation

Verify that the ResourceQuota `pod-limiter` exists in `quota-test` and has a hard limit of `pods: 2`.
