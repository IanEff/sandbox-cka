---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Scaling workloads", "Chapter 12 - Scaling workloads"]
---

# Concept - Scaling [[Topic - Workloads|workloads]]

- **Horizontal:** Number of pods.
- **Vertical:** Individual pod resources (CPU/RAM).

### Manual Scaling

```bash
kubectl scale deployment app-cache --replicas=256
# OR
kubectl edit deployment app-cache
```

### Autoscaling

Uses `HorizontalPodAutoscaler` (HPA).

- **Requires:** Metrics server + defined resource requests.
- **Imperative:**

  ```bash
  kubectl autoscale deployment app-cache --cpu-percent=80 --min=3 --max=5
  ```

**HPA YAML Example:**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-cache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app-cache
  minReplicas: 3
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

**Listing HPAs:**

```bash
kubectl get hpa
```

---
**Topics:** [[Topic - Tooling]], [[Topic - Workloads]]
