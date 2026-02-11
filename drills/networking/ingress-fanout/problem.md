# Ingress Fanout

## Problem

Create an Ingress resource named `shop-ingress` in the `default` namespace.

It should route traffic based on the following rules:
- Any traffic to path `/products` should be routed to the service `products-svc` on port 80.
- Any traffic to path `/checkout` should be routed to the service `checkout-svc` on port 80.

Use `implementationSpecific` path type for both.
The Ingress class should be `nginx` (if required by your cluster, otherwise leave standard).

Ensure the backend services exist (created by setup) but you only need to create the Ingress.
