# PV HostPath Permissions

**Drill Goal:** Configure a PersistentVolume with specific HostPath directory creation behavior.

## Problem

Create a PersistentVolume named `local-store` with the following requirements:
*   Capacity: `500Mi`
*   Access Mode: `ReadWriteOnce`
*   Storage Class: `manual`
*   Host Path: `/var/data/project-x`
*   **Crucial:** Ensure the directory is **automatically created** on the host if it does not exist.

Then:
1.  Create a PersistentVolumeClaim named `local-claim` in the `default` namespace to bind to this PV.
2.  Create a Pod named `writer` in the `default` namespace (image: `busybox`) that:
    *   Mounts this PVC at `/mnt/data`.
    *   Writes "Hello World" to `/mnt/data/index.html`.
    *   Sleeps forever (or `3600`).

## Validation

Verify the PV utilizes the correct `hostPath` type, the PVC is bound, and the Pod is running and has written the file.
