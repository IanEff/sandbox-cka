# Drill: Security Context Capabilities

## Question

**Context:**
Security guidelines require that containers drop all unnecessary Linux capabilities and only add specific ones needed for their operation.

**Task:**
Create a Pod named `secure-cap` in the `default` namespace.

* Image: `busybox`
* Command: `sleep 3600`
* **Security Context (Container API):**
    1. **Drop** ALL capabilities.
    2. **Add** only the `NET_ADMIN` capability.

ℹ️ You can verify the capabilities by looking at the Pod status or running `capsh --print` inside (if available) or checking `/proc/1/status`.

## Hints

* `securityContext.capabilities`
* `add: ["NET_ADMIN"]`
* `drop: ["ALL"]`
