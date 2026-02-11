# Drill: Inspector Gadget

The ServiceAccount `gadget-sa` in namespace `go-go` is supposed to be able to inspect secrets in the same namespace.
However, it seems to be malfunctioning.

**Your Task:**
Fix the RBAC/ServiceAccount configuration so that a pod running as `gadget-sa` can list secrets in the `go-go` namespace.
Do not grant cluster-wide permissions; keep it scoped to the namespace.

*Note: If `kubectl exec` fails with "pod does not exist", try verifying permissions using `kubectl auth can-i`.*
