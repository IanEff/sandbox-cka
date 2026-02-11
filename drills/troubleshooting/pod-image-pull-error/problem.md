# Pod Image Pull Error

**Drill Goal:** Diagonse and fix an image pull error.

## Problem

1.  A Pod named `typo-pod` is running in the `default` namespace.
2.  It is currently stuck in `ImagePullBackOff` or `ErrImagePull`.
3.  Identify the issue (the image name is valid `nginx` but we typed `nginxx`).
4.  Edit the Pod to fix the image name so it can start.

## Validation

Verify that the `typo-pod` is in `Running` state.
