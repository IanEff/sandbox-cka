# ConfigMap Volume Mount

## Instructions

Create a Pod named `logger` using the image `busybox` that runs the command `sleep 3600`.
Mount the ConfigMap named `log-conf` to the path `/etc/config`.

The ConfigMap `log-conf` already exists.

## Verification

The Pod `logger` must be running.
The file `/etc/config/log.properties` inside the pod must contain the content from the ConfigMap.
