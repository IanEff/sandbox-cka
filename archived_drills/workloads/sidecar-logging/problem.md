# Drill: Sidecar Logging

A Pod named `web-server` is running in the `default` namespace. It writes logs to `/var/log/web.log`.

**Task:**
Edit the Pod to add a sidecar container named `log-shipper` using the image `busybox`.
The sidecar should tail the log file `/var/log/web.log` to stdout using the command: `sh -c 'tail -f /var/log/web.log'`.

**Requirements:**
- Both containers must share a volume to access the log file.
- The Pod must remain running.
- Do not delete and recreate the Pod if possible (note: adding sidecars usually requires recreation or editing the manifest and forcing replace, but for the exam, editing the running pod directly might be blocked for immutable fields. However, you can save the manifest, delete, and apply. The goal is the final state).
