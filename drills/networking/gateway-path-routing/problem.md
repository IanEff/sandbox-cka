# Drill: Gateway Path Routing

## Question

**Context:**
The cluster has a Gateway implementation installed (e.g., Cilium).
The Namespace `gateway-lab` contains two Services: `echo-v1` and `echo-v2`.

**Task:**

1. Create a **Gateway** named `my-gateway` in `gateway-lab` (GatewayClassName: `cilium`). It should listen on port 80 (HTTP).
2. Create an **HTTPRoute** named `echo-route` in the same namespace, attached to `my-gateway`.
3. Configure the routing rules:
    * Requests matching the path prefix `/v1` must be forwarded to Service `echo-v1`.
    * Requests matching the path prefix `/v2` must be forwarded to Service `echo-v2`.

## Hints

* `backendRefs`
* `rules.matches.path.type: PathPrefix`
