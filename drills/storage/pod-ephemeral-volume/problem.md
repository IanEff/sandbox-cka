# Pod Ephemeral Volume

**Drill Goal:** Use a Generic Ephemeral Volume with a PVC template.

## Problem

Create a Pod named `temp-store` in `default` namespace (image `busybox`, command `sleep 3600`).
The Pod should have a volume named `scratch-vol` which is a **generic ephemeral volume**.
Details:
*   Mount Path: `/scratch`
*   Volume Claim Template must request `10Mi` storage and use `RWO` access mode.

## Validation

Verify that the Pod spec contains an `ephemeral` volume source with the correct template.
