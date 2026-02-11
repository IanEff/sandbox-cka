# Pod Privileged Mode

**Drill Goal:** Create a Pod running in privileged mode.

## Problem

Create a Pod named `root-access` in namespace `security-zone`.
*   Image: `busybox`
*   Command: `sleep 3600`
*   **Security Context:** The container must run in **privileged** mode.

## Validation

Verify that the `privileged` flag is set to `true` in the container's security context.
