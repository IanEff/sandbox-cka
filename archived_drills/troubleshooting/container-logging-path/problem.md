# Drill: The Silent Logger

## Scenario

A developer deployed a Pod named `logger` in the `trouble-logs` namespace. They claim the application is running and generating logs, but `kubectl logs -n trouble-logs logger` is returning output that is surprisingly empty.

## Task

1. Investigate the Pod `logger` in namespace `trouble-logs` to understand where it is writing its logs.
2. Fix the Pod configuration so that the application logs are visible via `kubectl logs`. You may need to recreate the Pod with the correct configuration.
3. Ensure the Pod name remains `logger`.

## Validation

Run `drill verify troubleshooting/container-logging-path` to confirm logs are flowing.
