# Drill: Pod Affinity Required

## Scenario

You need to deploy a redis cache that is co-located with the backend service for performance (using localhost or high-speed link assumptions, though here we just use affinity).

1. A "Backend" pod named `backend-app` exists in the `default` namespace with label `app=backend`. It is running on a specific node.
2. Create a Deployment named `redis-cache` with `2` replicas using image `redis:alpine`.
3. Configure **Pod Affinity** (not Node Affinity) so that the `redis-cache` pods are **required** to run on the same node as the `backend-app` pod (`topologyKey: kubernetes.io/hostname`).

## Constraints

- Deployment Name: `redis-cache`
- Affinity Type: `requiredDuringSchedulingIgnoredDuringExecution`
- Label Selector: match `app=backend`
