---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Chapter 15 - Volumes", "Volumes"]
---

# Concept - Volumes

### Volume Types

spec.containers[].volumeMounts[]

- `emptyDir`: Lifespan of the pod; used for inter-container data exchange.
- `hostPath`: On the host node's filesystem.
- `configMap`, `secret`: Injected data.
- `nfs`: Network file system.
- `persistentVolumeClaim`: Abstracted [[Topic - Storage|storage]].

### Creating and Accessing

**Declarative Example:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: business-app
spec:
  volumes:
  - name: shared-data
    emptyDir: {}
  containers:
  - name: nginx
    image: nginx:1.27.1
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  - name: sidecar
    image: busybox:1.37.0
    volumeMounts:
    - name: shared-data
      mountPath: /data
```

1. Declare volume in `spec.volumes[]`.
2. Mount in `spec.containers[].volumeMounts[]`.

---
**Topics:** [[Topic - Architecture]], [[Topic - Networking]], [[Topic - Storage]], [[Topic - Workloads]]
