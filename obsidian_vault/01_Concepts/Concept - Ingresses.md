---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Chapter 18 - Ingresses", "Ingresses"]
---

# Concept - Ingresses

HTTP/HTTPS-based client routing. Requires an Ingress Controller (e.g., NGINX, Application Gateway).

### Check Availability

```bash
kubectl get ingressclasses
```

### Ingress Rules

Conditions based on:

- `hosts`
- `paths`
- `backend` (ClusterIP Service name and port)

### Creating Ingresses

**Imperative:**

```bash
kubectl create ingress next-app \
  --rule="next.example.com/app=app-service:8080" \
  --rule="next.example.com/metrics=metrics-service:9090"
```

**Declarative:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: next-app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: next.example.com
    http:
      paths:
      - path: /app
        pathType: Exact
        backend:
          service:
            name: app-service
            port:
              number: 8080
```

## Interlude - Downward API

Runtime information about `Pods`, `Services` et cetera

Generally mounted as volumeMounts, for liiiiiiive updates:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: random-generator
spec:
  containers:
  - image: k8spatterns/random-generator:1.0
    name: random-generator
    volumeMounts:
    - name: pod-info                 # values from downward api mounted to the pod
      mountPath: /pod-info
  volumes:
  - name: pod-info
    downwardAPI:
      items:
      - path: labels                 # setting up the file 'labels' to contain all labels
        fieldRef:
          fieldPath: metadata.labels
      - path: annotations            # same, for annotations
        fieldRef:
          fieldPath: metadata.annotations
```

---
**Topics:** [[Topic - Networking]], [[Topic - Storage]], [[Topic - Tooling]], [[Topic - Workloads]]
