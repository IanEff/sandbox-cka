---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Resource Requirements, Limits, and Quotas", "Chapter 13 - Resource Requirements, Limits, and Quotas"]
---

# Concept - Resource Requirements, Limits, and Quotas

### QoS Classes

`Guaranteed`, `Burstable`, `BestEffort`.

#### Defining Resources

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rate-limiter
spec:
  containers:
  - name: business-app
    image: bmuschko/nodejs-business-app:1.0.0
    resources:
      requests:
        memory: "256Mi"
        cpu: "1"
      limits:
        memory: "512Mi"
```

**Rules of Thumb:**

- Always define memory requests and limits.
- For production: requests == limits (prevents eviction).
- Always define CPU requests.
- Avoid strict CPU limits for production (can cause throttling).

### Limit Ranges

Enforce default and min/max resource constraints within a namespace.

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-resource-constraint
spec:
  limits:
  - type: Container
    defaultRequest:
      cpu: 200m
    default:
      cpu: 200m
    min:
      cpu: 100m
    max:
      cpu: "2"
```

**Explore:** `kubectl describe limitrange cpu-resource-constraint`

---
**Topics:** [[Topic - Architecture]], [[Topic - Tooling]], [[Topic - Workloads]]
