# Drill: Network Isolation Policy

## Objective
Implement a NetworkPolicy to secure the `k2-prod` namespace.

## Instructions
1.  Target Namespace: `k2-prod`.
2.  Create a NetworkPolicy named `allow-qa-only`.
3.  The policy must:
    *   **Deny** all Ingress traffic from all namespaces by default.
    *   **Allow** Ingress traffic specifically from the `k2-qa` namespace.
    *   Allow traffic to all pods in `k2-prod`.
4.  Ensure that pods in `default` namespace (or any other) CANNOT access `k2-prod`.
5.  Ensure that pods in `k2-qa` CAN access `k2-prod`.

## Environment
*   Namespace `k2-prod` contains a service `prod-web` (port 80).
*   Namespace `k2-qa` contains a pod `qa-client`.
*   Namespace `default` contains a pod `stranger`.
