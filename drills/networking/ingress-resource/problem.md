# Ingress Resource Routing

## Scenario

You have two services in the `ingress-test` namespace, `svc-alpha` and `svc-beta`. You need to expose them via a single Ingress resource.

## Requirements

- **Namespace**: `ingress-test`
- **Host**: `my-app.com`
- **Ingress Name**: `main-ingress`
- **Paths**:
  - `/alpha` should route to Service `svc-alpha` on port `80`.
  - `/beta` should route to Service `svc-beta` on port `80`.
- **Ingress Class**: `cilium` (There is a Gateway Class `cilium` but usually Ingress class name is checked. Since environment uses GatewayAPI, check valid Ingress classes using `kubectl get ingressclasses`. If none exist, use `nginx` or leave default).
  - *Correction*: This cluster has Cilium installed which supports standard Ingress. Use `ingressClassName: cilium` if it exists, otherwise just ensure the resource is created correctly. *Hint*: Check valid IngressClasses.

## Verify

The drill checks if the Ingress rules are correctly defined.
