# Drill: Gateway Header Routing

Two versions of a web application (`v1` and `v2`) are deployed in the `drill-gateway` namespace, but they are not accessible from outside the cluster.

Your task is to expose them using a single **Gateway** and route traffic based on HTTP headers.

## Requirements

1. **Gateway**:
    * Name: `drill-gateway`
    * Namespace: `drill-gateway`
    * GatewayClass: `cilium`
    * Listen on port `80` (HTTP).

2. **HTTPRoute**:
    * Name: `header-route` (in `drill-gateway` namespace).
    * Ideally attached to the `drill-gateway` Gateway.
    * **Routing Rules**:
        * Requests with the header `Version: v2` must be routed to Service `v2` (port 80).
        * All other requests must be routed to Service `v1` (port 80).

## Verification

When configured correctly:

* `curl <GATEWAY_IP>` returns the Nginx default page (v1).
* `curl -H "Version: v2" <GATEWAY_IP>` returns "It works!" (Apache/v2).
