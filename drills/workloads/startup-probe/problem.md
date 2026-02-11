# Configure Startup Probe for Legacy App

## Objective
Configure a `startupProbe` to allow a slow-starting application enough time to initialize without being killed by the `livenessProbe`.

## Instructions
1.  There is a Deployment named `legacy-app` in the `default` namespace.
2.  The application takes approximately **60 seconds** to start up.
3.  The current `livenessProbe` is too aggressive and kills the container before it is ready, causing a CrashLoop.
4.  Modify the Deployment `legacy-app`:
    *   Add a `startupProbe` that checks the path `/healthz` on port 8080.
    *   The probe should run every **5 seconds**.
    *   It should allow up to **15 failures** before giving up.
    *   Do **NOT** modify the existing `livenessProbe` or `readinessProbe`.

## Verification
The Pods for `legacy-app` should transition to the `Running` state and eventually become `Ready`.
