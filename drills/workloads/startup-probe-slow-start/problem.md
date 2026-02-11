# Startup Probe for Slow Start

**Drill Goal:** Use Startup Probes to handle legacy applications with slow initialization times.

## Problem

The Deployment `legacy-app` in namespace `legacy` keeps restarting because its Liveness Probe kicks in before the application is ready.

Modify the Deployment to add a **Startup Probe** with the following configuration:
*   It should check the same endpoint/command as the Liveness Probe (or simply HTTP GET /).
*   It must give the application at least **60 seconds** to start up before the Liveness Probe takes over.
*   You can achieve this by configuring `failureThreshold` and `periodSeconds` appropriately.

## Validation

Verify that the Deployment has a Startup Probe configured and that the Pods are able to reach the Running state without crashing during startup.
