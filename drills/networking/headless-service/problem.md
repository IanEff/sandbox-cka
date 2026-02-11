# Headless Service for StatefulSet

A StatefulSet needs direct pod-to-pod communication without load balancing. The current service configuration is preventing proper DNS resolution for individual pods.

## Task

A StatefulSet named `database` with 3 replicas exists in the `data` namespace. Currently, there's a regular ClusterIP service that load-balances across all pods.

Create a headless Service named `database-headless` that:

- Selects pods with label `app=database`
- Exposes port 3306 (target port also 3306)
- Does NOT have a cluster IP (headless)
- Allows direct DNS resolution to individual pods (e.g., `database-0.database-headless.data.svc.cluster.local`)

Verify the service is created and DNS records are properly configured for individual pods.
