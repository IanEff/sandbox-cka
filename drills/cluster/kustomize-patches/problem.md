# Drill: Kustomize Patches

## Problem

In `~/kust-patch-drill`, there is a basic Nginx deployment.
However, the requirements have changed.

1. Create a `kustomization.yaml` in that directory (if not exists, or edit it).
2. Use a **strategic merge patch** (inline or file) to change the `Deployment` container command to `["sh", "-c", "sleep 3600"]`.
3. Apply the configuration using Kustomize.

## Hints

- `patchesStrategicMerge` or `patches` field in `kustomization.yaml`.
