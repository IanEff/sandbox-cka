# Default Deny & Allow Specific

In namespace `security-lockdown`:

1. Create a `Default Deny` NetworkPolicy named `deny-all-traffic` that blocks all Ingress traffic to all pods in the namespace.
2. Create a second NetworkPolicy named `allow-api` that allows traffic *only* to the `backend` pod (label `app=backend`) on port 80, specifically coming from the `frontend` pod (label `app=frontend`).

Existing resources:

- `backend` pod (80)
- `frontend` pod
- `rogue` pod
