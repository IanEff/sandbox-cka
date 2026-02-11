# Sidecar Logging

## Scenario

The pod `logger-app` in namespace `logging` writes its application logs to a file `/var/log/app.log`.
The monitoring system requires these logs to be available via `kubectl logs`.

## Requirements

- **Namespace**: `logging`
- **Pod**: `logger-app`
- **Task**: Update the Pod (you may need to replace it) to include a **sidecar container**.
  - Sidecar name: `log-adapter`
  - Image: `busybox` (or `alpine`)
  - Command: `tail -f /var/log/app.log`
  - Volume: Both containers must share the volume where the log file is written.

## Verification

The drill checks if the sidecar writes the correct log lines to its stdout.
