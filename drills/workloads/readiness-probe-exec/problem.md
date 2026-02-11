# Readiness Probe Exec

**Drill Goal:** Configure a custom script-based readiness check.

## Problem

1.  Create a Pod named `ready-checker` (image `busybox`) in the `default` namespace.
2.  The Pod main process should run `sleep 3600`.
3.  Configure a **Readiness Probe**:
    *   It should run the command `cat /tmp/health`.
    *   It should check every **5 seconds**.
4.  The Pod will not be ready initially because `/tmp/health` does not exist. This is expected.

## Validation

Verify that the readiness probe is correctly configured with the exec action and period.
