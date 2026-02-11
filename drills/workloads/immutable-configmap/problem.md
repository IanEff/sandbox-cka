# Drill: Immutable ConfigMap

## Problem

In the namespace `config-test`:

1. Create a ConfigMap named `locked-config` with the data `max_connections=100`.
2. Configure this ConfigMap to be **immutable** to prevent accidental updates and improve cluster performance.
3. Create a Pod named `consumer` (image: `nginx:alpine`) that mounts this ConfigMap as a volume at `/etc/config`.

## Hints

- `immutable: true` (Top level field in ConfigMap spec)
- Used to protect cluster data and allows Kubelet to cache the data indefinitely.
