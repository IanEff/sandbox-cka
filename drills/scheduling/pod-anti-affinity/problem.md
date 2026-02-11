# Drill: Pod Anti-Affinity (High Availability)

## Scenario

You are deploying a Redis cache that requires high availability.
Namespace: `anti-affinity`.

## Task

1. Create a Deployment named `redis-cache` in Namespace `anti-affinity`.
   - Image: `redis:alpine`
   - Replicas: `3`
   - Label: `app=redis-cache`
2. Configure **Pod Anti-Affinity** to ensure that **no two pods** of this Deployment are scheduled on the same node.
   - Use `requiredDuringSchedulingIgnoredDuringExecution`.
   - Topology Key: `kubernetes.io/hostname`.

## Notes

- If you only have one control plane and one worker node, one pod might remain `Pending`. That is acceptable for this drill (or untaint the control plane if you wish, but the drill focuses on the *configuration*).
- The key is the valid affinity rule.

## Hints

- `spec.template.spec.affinity.podAntiAffinity`
- matchLabels: `app: redis-cache`
