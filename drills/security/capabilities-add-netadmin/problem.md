# Capabilities Add NET_ADMIN

**Drill Goal:** Add specific Linux capabilities to a Pod.

## Problem

1.  Create a Pod named `net-master` in `default` namespace (image `busybox`, command `sleep 3600`).
2.  Grant the container the `NET_ADMIN` capability.
3.  Ensure the Pod runs.

## Validation

Verify `.spec.containers[0].securityContext.capabilities.add` contains `NET_ADMIN`.
