# Multi-Container Logging Sidecar

The pod `log-pod` is currently running a single container that writes logs to `/var/log/app.log`.

1. Update the pod `log-pod` to include a sidecar container named `sidecar`.
2. The sidecar should use the `busybox` image.
3. The sidecar must print the logs from `/var/log/app.log` to its own stdout (e.g., using `tail -f`).
4. Ensure both containers share the volume `log-vol`.

> **Warning**: You cannot update an existing Pod's restartPolicy or containers list (except adding ephemeral containers) easily in basic edit. You may need to delete and recreate the pod, or extract its manifest.
