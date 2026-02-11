# Drill: Liveness Probe Timeout

## Scenario

The application `slow-starter` in namespace `liveness-fail` takes 15 seconds to initialize.
However, the current Liveness Probe is checking too early and too aggressively, causing the container to restart indefinitely.

## Task

1. Analyze the crashing Pod `slow-starter`.
2. Update the Pod manifest (or recreate it) to fix the restart loop.
   - You must NOT remove the probe.
   - Configure `initialDelaySeconds` to safely cover the startup time (e.g., 20s).
   - Ensure the `periodSeconds` is reasonable (e.g., 10s).

## Hints

- `kubectl describe pod` to see the events.
- `initialDelaySeconds`
