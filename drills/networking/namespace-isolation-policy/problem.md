# Namespace Isolation Policy

Namespace `project-a` exists.

1. create a NetworkPolicy named `deny-all-ingress-from-other-ns` in namespace `project-a`.
2. It should deny all incoming traffic to all pods in `project-a`.
3. HOWEVER, it should allow traffic from pods **within** the same namespace (`project-a`). (Careful: This often requires two rules or a specific ingress rule).

Actually, simpler: Deny all ingress from OTHER namespaces. Allow all ingress from SAME namespace.
