# Multi-Container Adapter Pattern

We have a legacy application that writes logs to a file, but our logging infrastructure expects logs on `stdout`.

## Requirements

1. Namespace `adapter-drill` contains a Pod named `logger` (or a manifest for it).
2. The Pod currently runs a single container `main` that writes date-stamped logs to `/var/log/main.log` every second.
3. Update the Pod (you may need to delete and re-create it) to include a sidecar container named `adapter`.
4. The `adapter` container should use image `busybox`.
5. The `adapter` should stream the content of `/var/log/main.log` to its own `stdout` (e.g., using `tail -f`).
6. Ensure both containers share the volume correctly.

## Note

The `main` container is defined as:

```yaml
image: busybox
command: ["/bin/sh", "-c", "while true; do date >> /var/log/main.log; sleep 1; done"]
```
