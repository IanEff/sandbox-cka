---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Chapter 10 - ConfigMaps and Secrets", "ConfigMaps and Secrets"]
---

# Concept - ConfigMaps and Secrets

- Key-value pairs decoupled from pod lifecycle.
- Injected as environment variables or mounted as [[Concept - Volumes|volumes]].
- Stored in `etcd` (unencrypted by default).

### ConfigMaps

#### Creation

**Imperative:**

```bash
kubectl create configmap game-config \
  --from-literal=player_initial_lives=3 \
  --from-literal=OPENAI_API_KEY=kwfon23nfin45.... \
  --from-env-file=.env \
  --from-file=app-config.json \
  --from-file=/path/to/directory/
```

Just a mapping. You can point it at a data file or literal key-values.

**Declarative:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
data:
  DB_HOST: mysql-service
  DB_USER: backend
```

#### Adding it to the Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend
spec:
  containers:
  - image: bmuschko/web-app:1.0.1
    name: backend
    envFrom:
    - configMapRef:
        name: db-config
```

#### Inspecting

```bash
kubectl exec backend -- env
```

#### From a file (json or yaml)

JSON file db.json:

```json
{
    "db": {
      "host": "mysql-service",
      "user": "backend"
    }
}
```

YAML:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
data:
  db.json: |-
    {
       "db": {
          "host": "mysql-service",
          "user": "backend"
       }
    }
```

Application to pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend
spec:
  containers:
  - image: bmuschko/web-app:1.0.1
    name: backend
    volumeMounts:
    - name: db-config-volume
      mountPath: /etc/config
  volumes:
  - name: db-config-volume
    configMap:
      name: db-config
```

### Secrets

- Unencrypted by default.
- **Internal Types:** `generic` (Opaque), `docker-registry` (kubernetes.io/dockercfg), `tls` (kubernetes.io/tls).

**Creation Flags:**

- `--from-literal`
- `--from-env-file`
- `--from-file` (or directory)

**Imperative:**

```bash
kubectl create secret generic db-creds --from-literal=pwd=s3cre!
```

**Declarative:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-creds
type: Opaque
data:
  pwd: czNjcmUh # Base64 encoded
```

**Note:** For `Opaque`/`generic`, data must be base64 encoded:

```bash
echo -n 's3cre!' | base64
```

To use plaintext in YAML:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-creds
type: Opaque
stringData:
  pwd: s3cre!
```

**Retrieving:**

```bash
kubectl get secret db-creds -o yaml
```

**Basic-auth secret type:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-basic-auth
type: kubernetes.io/basic-auth
stringData:
  username: bmuschko
  password: secret
```

#### Injecting Secrets in Pods

Referencing in `spec.containers[].envFrom[]`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend
spec:
  containers:
  - image: bmuschko/web-app:1.0.1
    name: backend
    envFrom:
    - secretRef:
        name: secret-basic-auth
```

**Remapping/Renaming values:**
Use `spec.containers[].env[].valueFrom`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend
spec:
  containers:
  - image: bmuschko/web-app:1.0.1
    name: backend
    env:
    - name: USER
      valueFrom:
        secretKeyRef:
          name: secret-basic-auth
          key: username
    - name: PWD
      valueFrom:
        secretKeyRef:
          name: secret-basic-auth
          key: password
```

#### Files (Private Keys, TLS, Certs)

**Imperative:**

```bash
cp ~/.ssh/id_rsa ssh-privatekey
kubectl create secret generic secret-ssh-auth \
  --from-file=ssh-privatekey \
  --type=kubernetes.io/ssh-auth
```

**Mounting as a volume:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend
spec:
  containers:
  - image: bmuschko/web-app:1.0.1
    name: backend
    volumeMounts:
    - name: ssh-volume
      mountPath: /var/app
      readOnly: true
  volumes:
  - name: ssh-volume
    secret:
      secretName: secret-ssh-auth
```

---
**Topics:** [[Topic - Architecture]], [[Topic - Networking]], [[Topic - Security]], [[Topic - Storage]], [[Topic - Tooling]], [[Topic - Workloads]]
