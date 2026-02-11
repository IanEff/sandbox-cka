# CoreDNS Resolution Failure

Pods in the cluster cannot resolve service names or external domains. DNS queries are failing, preventing inter-service communication.

## Task

The CoreDNS pods are having issues, causing DNS resolution failures across the cluster.

Your tasks:

1. Investigate the CoreDNS deployment in the `kube-system` namespace
2. Identify and fix the issue preventing DNS resolution
3. Verify that DNS resolution works correctly

Test DNS resolution by:

- Creating a test pod and resolving `kubernetes.default.svc.cluster.local`
- Resolving an external domain like `google.com`

Both should succeed once CoreDNS is functioning properly.
