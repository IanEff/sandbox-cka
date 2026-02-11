# Drill: Legacy Ingress Path Rewrite

## Scenario

Two services, `svc-foo` and `svc-bar`, are running in your cluster. We need to expose them via a single Ingress resource using legacy Ingress (not Gateway API).

## Task

Create an Ingress resource named `minimal-ingress` in the `default` namespace:

1. **Ingress Class**: `cilium` (or `nginx` if you prefer/available, but use `cilium` for this cluster).
2. **Host**: `test.drill`.
3. **Paths**:
    - `/foo` routes to service `svc-foo` on port 80.
    - `/bar` routes to service `svc-bar` on port 80.
4. **Backend Type**: ImplementationSpecific or Prefix. Use `Prefix` for path matching.

## Context

Ensure the resource is valid `networking.k8s.io/v1`.
