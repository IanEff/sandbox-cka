# Canary Routing

We have deployed two versions of our application: `app-v1` and `app-v2` in the `canary-ns` namespace.
There is a Service named `canary-svc` that exposes the application.

**Task:**
Currently, `canary-svc` ONLY routes traffic to `app-v1`.
Modify the Service (or the Deployments) so that the Service routes traffic to **both** `app-v1` and `app-v2` pods approximately equally.

**Requirements:**
- Do not delete the deployments.
- The Service name must remain `canary-svc`.
- Traffic must reach both versions.
