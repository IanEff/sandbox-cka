# Egress NetworkPolicy: Restrict Outbound Traffic

The security team requires that pods in namespace `secure-app` can only communicate with specific destinations.

Your tasks:

1. Create a NetworkPolicy named `restricted-egress` in namespace `secure-app`
2. The policy should apply to all pods with label `role=api`
3. Allow egress traffic ONLY to:
   - DNS (UDP port 53) to the kube-system namespace (so DNS resolution works)
   - TCP port 5432 to pods with label `app=database` in namespace `secure-app`
4. All other egress traffic should be denied

## Verification

- Pods with `role=api` should be able to resolve DNS names
- Pods with `role=api` should be able to connect to the database on port 5432
- Pods with `role=api` should NOT be able to curl external sites or other internal services

**Hint**: Use `namespaceSelector` with `podSelector` for DNS access. The kube-system namespace needs appropriate labels.
