# Service Endpoints Missing

**Drill Goal:** Troubleshoot why a Service is not selecting any Pods.

## Problem

In the namespace `debug-me`:
1.  There is a Deployment named `web-app`.
2.  There is a Service named `web-service` that is supposed to expose the `web-app` Pods.

However, the Service currently has **no endpoints**.
Identify the issue and fix the Service configuration so that it correctly selects the `web-app` Pods.

## Validation

Verify that the Service `web-service` has endpoints associated with the `web-app` Pods.
