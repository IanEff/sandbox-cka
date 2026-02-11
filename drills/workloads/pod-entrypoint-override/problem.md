# Drill: Pod Entrypoint Override

## Problem

1.  Create a Pod named `override-pod` in the `default` namespace.
2.  Use the image `alpine`.
3.  The image usually runs `/bin/sh` or similar. We want to override the **ENTRYPOINT** (not just the CMD/Args) to run `sleep 3600`.
4.  Ensure the Pod is in `Running` state.

## Note
In Docker:
*   `ENTRYPOINT` -> Kubernetes `command`
*   `CMD` -> Kubernetes `args`

## Reference
*   <https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/>
