# Drill: HTTPRoute Header Match

## Question

**Context:**
The Namespace `gateway-test` contains a Gateway named `my-gateway`.
Two Services `web-service` and `android-service` act as backends.

**Task:**
Create a new `HTTPRoute` named `mobile-route` in Namespace `gateway-test`.

* It should be attached to the existing Gateway `my-gateway`.
* Traffic with the HTTP Header `User-Agent` set exactly to `Android` should be forwarded to `android-service` on port 80.
* All other traffic should be forwarded to `web-service` on port 80.

ℹ️ The Gateway API CRDs are already installed. You do not need to create a GatewayClass.

## Hints

* `spec.rules.matches`
* `headers`
* `type: Exact`
