# Traffic Splitting with Gateway API

Traffic shifting is a core capability of the Gateway API. You have been tasked to roll out a new version of the color application.

## Requirements

1. Work in namespace `gateway-drill`. This namespace and the applications `blue` and `green` have been created for you.
2. Create a `Gateway` named `color-gateway` using the `cilium` GatewayClass. It should listen on port 80 for all hostnames.
3. Create an `HTTPRoute` named `color-route` attached to `color-gateway`.
4. Configure the route to split traffic for path `/` (prefix match):
   - **80%** of requests go to service `blue` on port 80.
   - **20%** of requests go to service `green` on port 80.

## Tips

- The services `blue` and `green` are already ClusterIP services exposed on port 80.
- Use `apiVersion: gateway.networking.k8s.io/v1`.
