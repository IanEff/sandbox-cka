# Gateway API Path Routing

Expose the `echo` Service in namespace `networking-6` using the Gateway API.

1. A `Gateway` named `cilium-gateway` already exists (or creates one) in `networking-6` using `gatewayClassName: cilium`.
2. Create an `HTTPRoute` named `echo-route` that:
    * Attaches to the `cilium-gateway`.
    * Matches traffic with path prefix `/v1/echo`.
    * Routes to Service `echo` on port 80.

Ensure the route is Accepted.
