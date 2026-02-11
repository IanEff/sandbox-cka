# Resource Quotas and Limits

A namespace is consuming too many cluster resources. You need to implement resource quotas to prevent resource exhaustion.

## Task

The `team-blue` namespace exists but has no resource constraints. Create a ResourceQuota named `team-quota` in the `team-blue` namespace that enforces:

- Maximum of 5 pods
- Maximum of 2 CPU cores total (requests)
- Maximum of 4Gi memory total (requests)
- Maximum of 2 persistent volume claims

Then create a LimitRange named `default-limits` in the same namespace that sets default container limits:

- Default CPU limit: 500m
- Default memory limit: 512Mi
- Default CPU request: 100m
- Default memory request: 128Mi

Verify both resources are created and active.
