# Sidecar Logging Pattern

There is a Pod named `logger` in namespace `workloads-1`.
The application application container `app` writes its logs to a file at `/var/log/legacy-app.log` instead of stdout.
It rotates these logs very quickly, so we need to stream them.

Modify the Pod `logger` to include a sidecar container named `adapter`.
The `adapter` container should:

1. Use the image `busybox`.
2. Mount the same volume as the `app` container (volume is already defined as `log-vol`).
3. Run a command that tails the `/var/log/legacy-app.log` file to stdout (e.g., `tail -f`).

Ensure the Pod is running and the logs can be retrieved via `kubectl logs logger -c adapter -n workloads-1`.

> Note: You will need to delete and re-create the Pod since you cannot add containers to an existing Pod. A manifest has been provided in the setup, but you might want to extract the current one first.
