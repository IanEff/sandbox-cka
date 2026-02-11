# Automount ServiceAccount Token

**Drill Goal:** Secure pod identity by disabling automatic ServiceAccount token mounting.

## Problem

1.  Create a ServiceAccount named `secure-bot` in the `default` namespace.
2.  Configure this ServiceAccount (or the Pods that use it) so that the API token is **NOT** automatically mounted into the Pods.
3.  Create a Pod named `paranoid-pod` (image `nginx:alpine`) that uses this ServiceAccount.

## Validation

Verify that `paranoid-pod` runs but does **not** have the ServiceAccount token mounted at `/var/run/secrets/kubernetes.io/serviceaccount`.
