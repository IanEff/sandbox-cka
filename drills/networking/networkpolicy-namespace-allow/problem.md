# Drill: NetworkPolicy Namespace Isolation

## Scenario

Secure the `restricted` namespace.

1. Create a `NetworkPolicy` named `allow-trusted-only` in the `restricted` namespace.
2. It should **deny all incoming traffic** (Ingress) to all pods in `restricted` by default.
3. It should **allow** incoming traffic on TCP port **80** ONLY from pods located in the namespace `trusted`.

## Constraints

- Namespace `restricted` and `trusted` exist.
- Target Pods: All pods in `restricted`.
- Source Pods: Any pod in `trusted`.
- Port: 80.
