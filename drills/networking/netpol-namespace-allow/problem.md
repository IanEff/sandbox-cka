# NetworkPolicy Namespace Allow

## Problem

Create a NetworkPolicy named `allow-client` in the `backend` namespace.

This policy should:
- Apply to pods in `backend` namespace (you can select all pods or a specific app, but usually selecting all is safer if not specified. Let's assume apply to ALL pods in backend).
- **Allow** ingress traffic on port 80.
- **BUT ONLY** from Pods that have the label `app=client` located in the `frontend` namespace.
- Deny all other ingress traffic to port 80 (implied by whitelist).

Ensure you use `namespaceSelector` and `podSelector` correctly.
