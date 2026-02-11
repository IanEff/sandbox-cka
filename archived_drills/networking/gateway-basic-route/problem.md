# Drill: Gateway API Basic Route

## Scenario

We are transitioning from Ingress to the Gateway API. The infrastructure team has already set up a `GatewayClass` named `cilium` (or uses the default) and a `Gateway` named `main-gateway` in the `gateway-drill` namespace.

A web application `color-app` is running and exposed via a Service named `color-service` on port 80.

## Task

Create an `HTTPRoute` named `color-route` in the `gateway-drill` namespace that:

1. Attaches to the `main-gateway`.
2. Matches traffic with the hostname `colors.example.com`.
3. Forwards traffic to the `color-service` on port 80.

## Validation

Run `drill verify networking/gateway-basic-route` to check your work.
