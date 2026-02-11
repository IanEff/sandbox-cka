# Gateway Gauntlet

The team is adopting the Kubernetes Gateway API.
A Service `web-service` exists on port `8080`.
A Gateway `web-gateway` and an HTTPRoute `web-route` have been created to expose it.

However, traffic is not flowing to the service as expected.

**Tasks:**
1.  Identify the configuration error in the `HTTPRoute` named `web-route`.
2.  Fix the `HTTPRoute` so it correctly references the `web-service` port.
