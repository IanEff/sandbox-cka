---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Chapter 16 - Persistent Volumes", "Persistent Volumes"]
---

# Concept - Persistent [[Concept - Volumes|Volumes]]

### PersistentVolume Types

`hostPath`, `local`, `nfs`, `csi`, `fc` (fibre channel), `iscsi`.

### Provisioning

- **Static:** Admin manually creates the PV.
- **Dynamic:** Automatically created using `StorageClassName`.

#### Static Provisioning

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/db
```

Apply: `kubectl apply -f db-pv.yaml`
Check: `kubectl get pv db-pv`

#### Configuration Options

- **Volume Mode (`spec.volumeMode`):** `Filesystem` (default) or `Block`.
- **Access Modes (`spec.accessModes`):** `ReadWriteOnce`, `ReadOnlyMany`, `ReadWriteMany`, `ReadWriteOncePod`.
- **Reclaim Policy (`spec.persistentVolumeReclaimPolicy`):** `Retain` (manual), `Delete`.
- **Node Affinity (`spec.nodeAffinity`):** Ensures pod stays on a node that can access the volume.

**Example with Node Affinity:**

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 10Gi
  accessModes: ["ReadWriteOnce"]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/data
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values: ["node01", "node02"]
```

### Creating PersistentVolumeClaims (PVC)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-pvc
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: "" # Empty string for static provisioning
  resources:
    requests:
      storage: 256Mi
```

Status should move to `Bound`.

**Binding to a specific volume:**

```yaml
spec:
  volumeName: db-pv
```

### Mounting a PVC to a Pod

Reference in `spec.volumes[]` and `spec.containers[].volumeMounts[]`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-consuming-pvc
spec:
  volumes:
  - name: app-storage
    persistentVolumeClaim:
      claimName: db-pvc
  containers:
  - image: alpine:3.22.2
    name: app
    volumeMounts:
    - mountPath: "/mnt/data"
      name: app-storage
```

Check: `kubectl describe pvc db-pvc`

### [[Topic - Storage|Storage]] Classes

Query: `kubectl get storageclass`

**Example (Google Cloud PD):**

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
```

**Using a Storage Class in PVC:**

```yaml
spec:
  storageClassName: fast
  resources:
    requests:
      storage: 512Mi
```

---
**Topics:** [[Topic - Architecture]], [[Topic - Security]], [[Topic - Storage]], [[Topic - Tooling]], [[Topic - Workloads]]
