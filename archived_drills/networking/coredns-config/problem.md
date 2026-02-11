# CoreDNS Trouble

Pods in the `dns-test` namespace cannot resolve the Kubernetes service `my-svc.dns-test.svc.cluster.local`.

The service exists and has endpoints. Other pods in other namespaces can resolve services normally.

Investigate and fix the issue.

**Constraints:**
- The CoreDNS deployment must remain running.
- The fix must persist through CoreDNS pod restarts.
