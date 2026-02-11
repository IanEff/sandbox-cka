# Drill: Pod Priority Class

## Question

**Context:**
You need to ensure that a critical workload takes precedence over others in scheduling.

**Task:**

1. Create a **PriorityClass** named `mission-critical`.
    * Value: `1000000`
    * Ensure it cannot be preempted if you want (optional, but focus on the value).
2. Create a Pod named `critical-pod` in the `default` namespace.
    * Image: `nginx:1.27`
    * Assign it the `mission-critical` PriorityClass.

## Hints

* `apiVersion: scheduling.k8s.io/v1`
* `kind: PriorityClass`
* `priorityClassName` field in Pod spec.
