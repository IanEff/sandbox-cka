# Certified Kubernetes Administrator study guide

## Chapter 0

### Useful commands to keep in mind

- Pull all resources' shortnames:

  ```bash
  kubectl api-resources
  ```

- Explain a resource:

  ```bash
  kubectl explain <resource>
  ```

## Chapter 2 - Kubernetes breakdown

- **Control plane node**
  - API server
  - Scheduler
  - Controller manager
    - Watches for change
  - EtcD
    - Key-value store with all k8s cluster data
- **Common node components**
  - kubelet
    - keeps all containers in a pod running
  - kube proxy
    - maintains network rules
  - container runtime

## Chapter 3 - Primitives and objects

e.g.

- Pods
- Deployments
- Services

### Creating objects

```bash
kubectl run
kubectl create
```

- Fails if resource exists.

### Updating objects

```bash
kubectl edit
```

- Opens editor with the raw config of the live object & applies changes on save
- Note: You can define a `KUBE_EDITOR` if `EDITOR` is being difficult.

```bash
kubectl patch
```

- Directly patches the live object's manifest by way of JSON with the `-p` flag.

### Deleting objects

```bash
kubectl delete pod nginx --now
```

### Declarative object management

- Creates, updates, all with `apply`.
- Keeps track of changes with the key `kubectl.kubernetes.io/last-applied-configuration`.

## Chapter 4

Fucking vagrant. Use `cloud-image/ubuntu-24.04`.

### Speed-ups: local pull-through caches (OrbStack)

This repo can optionally use a **single local cache container** (runs in OrbStack with host networking) to reduce repeated downloads across reprovisioning:

- APT package cache via `apt-cacher-ng`
- OCI image pull-through caches for `registry.k8s.io`, `docker.io`, etc.
- Optional generic HTTP(S) caching via `squid`

Quick usage:

- Start cache: `scripts/cache.sh up`
- Stop cache: `scripts/cache.sh down`

More details are in `cache/README.md`.

- **kubeadm**
  - **Networks:** `eth0` internal .... pull from document script when you're less bored by this.
  - 2gb+ 2cpu (control plane), 6443 open on machines

    ```bash
    nc 127.0.0.1 6443 -zv -w 2
    ```

  - `swapoff` (for kubelet)
  - Need container runtime
  - Install `kubeadm`, `kubelet`, and `kubectl` from `pkgs.k8s.io`
  - Configure `cgroup` driver (this is _ignored_ in the book)

**Documented in Vagrantfile**

- `kubeadm` takes `--pod-network-cidr` and `--apiserver-advertise-address`
- Retrieve token join with `kubeadm token create --print-join-command`

  ```bash
  kubeadm join 192.168.56.10:6443 --token ziy4r9.1kqgqrgdh30d5gl7 --discovery-token-ca-cert-hash sha256:2f7054a066bedc7d8fb1d37bc38024c551fa2f91f9b0550420e9ce4b4af35c1c
  ```

- **Install CNI** -- flannel or :> [!WARNING]
  > whatever

- **Interlude: Install Helm**
  - Installing via Helm means you don't have to download the CNI manifest and edit it manually.
  - Robot says _download the manifest and install it manually._
  - **Apply install:**
    1. `curl -L0 .../kube-flannel.yml`
    2. `vim ...` (just edit the Network)
    3. `kubectl apply -f ...`
  - **Helm install:**
    1. Create `kube-flannel` namespace.
    2. Label it:

       ```bash
       kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged
       ```

    3. This label sets the namespace to be privileged so flannel can do its thing.
    4. Install:

       ```bash
       helm repo add flannel https://flannel-io.github.io/flannel/
       helm install flannel --set podCidr="192.168.56.0/24" --namespace kube-flannel flannel/flannel
       ```

### Cluster upgrade

- **Drain control plane node (evict workloads):**

  ```bash
  kubectl drain <node-name> --ignore-daemonsets
  ```

- **Actually edit the package repo to point to the right version:**

  ```bash
  sudo sed -i 's/v1.33/v1.34/g' /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-cache madison kubeadm # shows available versions in new repo
  sudo apt-get install -y --allow-change-held-packages kubeadm=1.34.3-1.1 # pins and upgrades
  sudo kubeadm upgrade plan
  sudo kubeadm upgrade apply v1.34.3
  kubectl drain <control plane nodename> --ignore-daemonsets
  ```

- **Upgrade kubelet and kubectl to the same version:**

  ```bash
  sudo apt-mark unhold kubelet kubectl && \
  sudo apt-get update && \
  sudo apt-get install -y kubelet=1.31.5-1.1 kubectl=1.31.5-1.1 && \
  sudo apt-mark hold kubelet kubectl
  ```

- **Reload daemons and restart kubelet:**

  ```bash
  sudo systemctl daemon-reload && sudo systemctl restart kubelet
  ```

- **On workers:**
  1. Upgrade the repos and `kubeadm`.
  2. sudo kubeadm upgrade node
  3. Upgrade the `kubelet` config:

     ```bash
     sudo kubeadm upgrade node
     ```

  4. Drain the node:

     ```bash
     kubectl drain <node-name> --ignore-daemonsets
     ```

  5. Upgrade `kubelet` and `kubectl`.

### Chapter 4 questions

1. **Create cluster; run nginx:**

   ```bash
   kubectl run <name> --image=nginx:1.29-apline --port 80
   ```

2. **Identify the node the pod has been scheduled:**

   ```bash
   $ kubectl get pod zingaboom -o wide
   NAME        READY   STATUS    RESTARTS   AGE     IP           NODE             NOMINATED NODE   READINESS GATES
   zingaboom   1/1     Running   0          3m52s   10.244.1.7   ubukubu-node-1   <none>           <none>
   ```

   ```bash
   $ kubectl drain ubukubu-node-1 --ignore-daemonsets --delete-emptydir-data
   node/ubukubu-node-1 cordoned
   error: unable to drain node "ubukubu-node-1" due to error: cannot delete cannot delete Pods that declare no controller (use --force to override): default/zingaboom, continuing command...
   There are pending nodes to be drained:
    ubukubu-node-1
   cannot delete cannot delete Pods that declare no controller (use --force to override): default/zingaboom
   <.....>
   ```

   Forced it, then...

   ```bash
   kubectl uncordon ubukubu-node-1
   ```

## Chapter 5 - Backing up and restoring etcd

Install `etcdctl` and `etcdutl` on the control plane node.

etcdctl is a `client` & needs the ca-cert

ETCDCTL_API=3 etcdctl --endpoints $ENDPOINT snapshot save snapshot.db --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key

- Go here and run the script: [etcd releases](https://github.com/etcd-io/etcd/releases)
- Establishing your `etcd` version:

  ```bash
  kubectl -n kube-system describe pod etcd-ubukubu-control | grep Image
  ```

  Example: `v3.6.5`

  ```bash
  wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-arm64.tar.gz
  ```

- **Important things to notice:**

  ```bash
  kubectl describe -n kube-system pod etcd-ubukubu-control
  ```

  - `--cert-file=/etc/kubernetes/...`
  - `--key-file=...`
  - `--listen-client-urls=<all these cert files>`

### Backing up etcd

[Use this command](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#built-in-snapshot)

```bash
export ENDPOINT=<listen-client-urls value>
ETCDCTL_API=3 etcdctl --endpoints $ENDPOINT snapshot save snapshot.db
```

**Alternative method (using certs):**

```bash
ETCDCTL_API=3 etcdctl \
  --cacert=<peer-trusted-ca-file> \
  --cert=<cert-file> \
  --key=<key-file> \
  snapshot save /path/to/etcd-backup.db
```

Example:

```bash
sudo ETCDCTL_API=3 etcdctl \
  --cacert=/etc/kubernetes/pki/etcd/server.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save snapshot.db
```

### Restoring etcd

```bash
sudo ETCDCTL_API=3 etcdutl --data-dir=/var/lib/from-backup snapshot restore snapshot.db
vim /etc/kubernetes/manifests/etcd.yaml
```

- In `spec: volumes: hostPath: path:`, change to `/var/lib/from-backup`.

**INVEST THE TIME TO BOOKMARK EVERYTHING**

## Chapter 6 - Permissions and RBAC

### Creating a new user

1. **Create an SSL key:**

   ```bash
   openssl genrsa -out <username>.key 2048
   ```

2. **Create a Certificate Signing Request (CSR):**

   ```bash
   openssl req -new -key <username>.key -out <username>.csr -subj "/CN=<username>/O=<groupname>"
   ```

3. **Register user in Kubernetes:**

   ```bash
   kubectl config set-credentials ian \
     --client-key=ian.key \
     --client-certificate=ian.csr \
     --embed-certs=true
   ```

   ```bash
   kubectl config get-users
   ```

### Creating a Service Account

- `kubectl create serviceaccount log-bot -n production`

### RBAC Concepts

`{subject, resource, verb}`

- **Subject:** User or Service Account.
- **Resource:** API resource type (e.g., pods, services).
  - Check with: `kubectl api-resources -o wide`
- **apiGroup** The API group, chief
- **Verb:** Actions = {`create`, `get`, `list`, `watch`, `delete`, `update`, `patch`.}

An empty set of double quotes (“”) in the apiGroups field indicates the core API group.

### API Primitives for RBAC

`Account <--> RoleBinding <--> Role <--> Resource`

- **Role:** Defines the API resources and their permitted operations.
  - e.g., "Allow listing and deleting pods."
- **RoleBinding:** Binds a Role to a Subject.
  - e.g., "Bind the role that permits updating Services to the user Ian."

ClusterRols & roles

**Default Roles:** `cluster-admin`, `admin`, `edit`, `view`.

### Creating a Role

**Imperative:**

```bash
kubectl create role read-only --verb=list,get,watch \
  --resource=pods,deployments,services
```

**YAML:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: read-only
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["list", "get", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["list", "get", "watch"]
```

### Creating a RoleBinding

**Imperative:**

```bash
kubectl create rolebinding read-only-binding --role=read-only --user=ian
```

**YAML:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-only-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: read-only
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: ian
```

### Inspecting Roles

```bash
kubectl get roles
kubectl get rolebindings
kubectl describe role read-only
kubectl describe rolebinding read-only-binding
```

### Switching Contexts

After adding the user, approve them and add to a context:

```bash
kubectl certificate approve ian
kubectl config use-context ian
```

### Cluster-wide RBAC

Use `ClusterRole` and `ClusterRoleBinding` for cluster-level permissions.

### Aggregated ClusterRoles

Add a label to a `ClusterRole`, then create an aggregating `ClusterRole` that uses an `aggregationRule` with `clusterRoleSelectors`.

**Example:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: list-pods
  labels:
    rbac-pod-list: "true"
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pods-services-aggregation-rules
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac-pod-list: "true"
  - matchLabels:
      rbac-service-delete: "true"
rules: []
```

- **Note:** Naming is important; append `--aggregation-rules` or similar to the name.
- **Pods** have access to the `default` service account. This grants them:
  - `system:discovery`
  - `system:basic-user`
  - `system:service-account-lookup`

## Chapter 7 - Operators and CRDs

**Operator:** A plugin to the platform that deploys, scales, upgrades, and manages apps.

- Consists of one or more CRDs (Custom Resource Definitions), a controller, and usually RBAC rules.

### ArgoCD Installation Saga

#### 1. Installing the Operator

From ArgoCD's page on `operatorhub.io`:

```bash
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.38.0/install.sh | bash -s v0.38.0
kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
```

(Installs into `operators` namespace)

#### 2. Monitoring Installation

```bash
kubectl get csv -n operators
```

#### 3. Creating a Custom Resource

Create a custom resource (e.g., Application) with YAML and deploy with `kubectl apply -f`.
View with:

```bash
kubectl describe application nginx
```

#### 4. Controllers

**Controller:** Performs the reconciliation loop by observing the state of the CR object and making API calls to reach the desired state.

### Installing Operators (Best Practice)

- Always check `operatorhub.io`.
- If problematic, find the community/official version on GitHub.
  - e.g., [MongoDB Operator Installation](https://github.com/mongodb/mongodb-kubernetes-operator/blob/master/docs/install-upgrade.md#procedure-using-kubectl)

## Chapter 8 - Helm and Kustomize

### Helm

Artifact Hub is the primary source for charts.

- **Updating all repos:**

  ```bash
  helm repo update
  ```

- **Adding a repo:**

  ```bash
  helm repo add <name> <url>
  ```

- **Installing a chart (e.g., Jenkins):**

  ```bash
  helm install my-jenkins jenkinsci/jenkins --version 5.8.114
  ```

- **Show default values:**

  ```bash
  helm show values jenkinsci/jenkins
  ```

- **Uninstalling:**

  ```bash
  helm uninstall my-jenkins
  ```

- **Overriding values during install:**

  ```bash
  helm install my-jenkins jenkinsci/jenkins --version 4.6.4 \
    --set controller.adminUser=boss \
    --set controller.adminPassword=password \
    -n jenkins --create-namespace
  ```

- **Upgrading:**

You can modify the objects the chart rolls out with upgrades.

  ```bash
  helm upgrade my-jenkins jenkinsci/jenkins --version 5.8.114
  ```

  ```bash
  helm upgrade broken-app <chart_path_or_repo/chart_name> \
    --namespace default \
    --set image.repository=nginx \
    --set image.tag=alpine
  ```

For anonymous tricky bullshit drill problems, sometimes the location of the chart isn't obvious.

1. Retrieve the chart name

```bash
~/p/k/sandbox-kcna ❯❯❯ helm list                                             sandbox-kcna ⎇ main ⌫3?3+-43
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART             APP VERSION
broken-app      default         1               2026-01-03 15:15:28.676840684 +0000 UTC deployed        mychart-0.1.0     1.16.0
```

1. Create an overrides file:

```yaml
image:
  repository: nginx
  tag: latest
```

1. Apply the overrides with the upgrade operation
`helm upgrade broken-app mychart-0.1.0 -n default -f fix-values.yaml`

- **Searching for charts:**

  ```bash
  helm search repo stack
  ```

### Kustomize

Simplifies manifest management via overlays and patches.

- **Rendering manifests (stdout):**

  ```bash
  kubectl kustomize ./path/to/kustomization/dir
  ```

- **Applying manifests:**

  ```bash
  kubectl apply -k ./path/to/kustomization/dir
  ```

Requires a `kustomization.yaml` file listing resources and patches.

## Chapter 9 - Pods and Namespaces

### The `run` command

Imperative way to create a pod:

```bash
kubectl run hazelcast --image=hazelcast/hazelcast:latest \
  --port=5701 \
  --env="DNS_DOMAIN=cluster" \
  --labels="app=hazelcast,env=prod"
```

- `--rm true`: Deletes pod after the container finishes.
- `--env`: Set environment variables.
- `--labels`: Set labels.

**Declarative way (YAML):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hazelcast
  labels:
    app: hazelcast
    env: prod
spec:
  containers:
  - name: hazelcast
    image: hazelcast/hazelcast:5.1.7
    env:
    - name: DNS_DOMAIN
      value: cluster
    ports:
    - containerPort: 5701
```

### Navigating Pods

```bash
kubectl get pods hazelcast       # By pod name
kubectl get pods -l app=hazelcast # By label
```

### Pod Lifecycle and Management

- **Lifecycle:** `Pending` -> `Running` -> `Succeeded`/`Failed`/`Unknown`
- **Container Lifecycle:** `Waiting` -> `Running` -> `Terminated`
- **Restart Policies:** `always`, `OnFailure`, `Never`

#### Inspecting Pods

```bash
kubectl describe pods hazelcast
kubectl describe pods hazelcast | grep Image:
```

#### Logs

```bash
kubectl logs hazelcast
```

#### Executing Commands

```bash
kubectl exec -it hazelcast -- /bin/bash
```

### Temporary and Network Info

- **Run temporary pod:**

  ```bash
  kubectl run busybox --image=busybox:1.37.0 --rm -it --restart=Never -- env
  ```

- **Find Pod IP:**

  ```bash
  kubectl get pod nginx -o wide
  # OR
  kubectl get pod nginx -o yaml
  ```

**Note:** Each node gets a subnet. Each pod gets a unique IP from the networking lifecycle manager (`kube-proxy`) along with DNS and CNI.

### Pod Configuration

#### Environment Variables

Defined in `spec.containers[].env`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: spring-boot-app
spec:
  containers:
  - name: spring-boot-app
    image: springio/gs-spring-boot-docker
    env:
    - name: SPRING_PROFILES_ACTIVE
      value: dev
    - name: VERSION
      value: '1.5.3'
```

#### Command and Arguments

Maps to `ENTRYPOINT` and `CMD` in Docker.

**Imperative:**

```bash
kubectl run mypod --image=busybox:1.36.1 -o yaml --dry-run=client \
  -- /bin/sh -c "while true; do date; sleep 10; done"
```

**Declarative:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: busybox:1.36.1
    command: ["/bin/sh"]
    args: ["-c", "while true; do date; sleep 10; done"]
```

### Namespace Management

- **Switch namespace for current context:**

  ```bash
  kubectl config set-context --current --namespace=<namespace>
  ```

- **Check current namespace:**

  ```bash
  kubectl config view --minify | grep namespace:
  ```

## Chapter 10 - ConfigMaps and Secrets

- Key-value pairs decoupled from pod lifecycle.
- Injected as environment variables or mounted as volumes.
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

## Chapter 11 - Deployments and ReplicaSets

- **ReplicaSet:** An API resource that ensures a specific number of identical pod instances are running.
- **Deployment:** A controller that manages ReplicaSets, providing declarative updates and rollbacks.

### Deploying ReplicaSets

**Command to generate YAML:**

```bash
kubectl create deployment app-cache --image memcached:latest --replicas=4 \
  --dry-run=client -o yaml
```

**Resulting YAML:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: app-cache
  name: app-cache
spec:
  replicas: 4
  selector:
    matchLabels:
      app: app-cache
  template:
    metadata:
      labels:
        app: app-cache
    spec:
      containers:
      - image: memcached:latest
        name: memcached
```

**Note:** Labels must match in three places:

1. `metadata.labels`
2. `spec.selector.matchLabels`
3. `spec.template.metadata.labels`

**Workload Primitives:**

- **Deployment:** For stateless apps.
- **StatefulSet:** For stateful apps (persistent identity/storage).
- **DaemonSet:** Ensures one instance per node.

### Updates and Rollbacks

- **Edit live deployment:**

  ```bash
  kubectl edit deployment app-cache
  ```

- **Update container image imperatively:**

  ```bash
  kubectl set image deployment web-server nginx=nginx:1.28.0
  ```

- **Rolling Updates Process:**
  1. Update logic (e.g., `set image`).
  2. Check status: `kubectl rollout status deployment app-cache`
  3. View history: `kubectl rollout history deployment app-cache`

- **Annotating changes (for history):**

  ```bash
  kubectl annotate deployment app-cache kubernetes.io/change-cause="memcached upgraded to 1.6.40"
  ```

- **Rolling back:**

  ```bash
  kubectl rollout undo deployment app-cache --to-revision=1
  ```

## Chapter 12 - Scaling workloads

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

## Chapter 13 - Resource Requirements, Limits, and Quotas

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

## Chapter 14 - Pod Scheduling

**The Scheduler process:**

1. **Filter:** Find nodes with enough resources.
2. **Score:** Rank capable nodes.
3. **Bind:** Assign the pod to the best node.

**Identify node allocation:**

```bash
kubectl get pod nginx -o wide
# OR
kubectl describe pod nginx | grep Node:
```

### Scheduling Options

#### 1. Node Selector

Uses labels for simple placement.

```bash
kubectl label node node01 disk=ssd
```

```yaml
spec:
  nodeSelector:
    disk: ssd
```

#### 2. Node Affinity

More expressive than node selectors.

```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disk
            operator: In
            values: ["ssd", "hdd"]
```

**Affinity Operators:** `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt`.

### Taints and Tolerations

- **Taint:** Assigned to a **Node** to repel pods.
- **Toleration:** Assigned to a **Pod** to allow it to be scheduled on a tainted node.

**Taint Effects:**

- `NoSchedule`: No new pods unless they tolerate.
- `PreferNoSchedule`: Scheduler tries to avoid the node.
- `NoExecute`: Existing pods are evicted if they don't tolerate.

**Taint Command:**

```bash
kubectl taint node node01 special=true:NoSchedule
```

**Pod Toleration YAML:**

```yaml
spec:
  tolerations:
  - key: "special"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

### Pod Topology Spread Constraints

Distributes pods across topology domains (e.g., zones).

```yaml
spec:
  topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app: web
```

- **Note:** These are only checked during initial scheduling, they don't rebalance.

## Chapter 15 - Volumes

### Volume Types

spec.containers[].volumeMounts[]

- `emptyDir`: Lifespan of the pod; used for inter-container data exchange.
- `hostPath`: On the host node's filesystem.
- `configMap`, `secret`: Injected data.
- `nfs`: Network file system.
- `persistentVolumeClaim`: Abstracted storage.

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

## Chapter 16 - Persistent Volumes

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

### Storage Classes

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

## Chapter 17 - Services

"The front end of a `Service` provides an IP address, DNS name, and port that is guaranteed to be stable for the life of the `Service`.  The back-end load-balances traffic over a dynamic set of `Pods`, the `EndPointSlice`, that match a label selector."

### Service Types

- **ClusterIP:** Internal-only IP. Good for microservice communication.
- **NodePort:** Exposes the service on a static port on every node.
- **LoadBalancer:** Uses cloud provider's external load balancer.

**Note:** NodePort builds on ClusterIP; LoadBalancer builds on NodePort.

### Port Mapping

- `spec.ports[].port`: Port exposed by the Service.
- `spec.ports[].targetPort`: Port the container is listening on in the Pod.
- `spec.containers[].ports[].containerPort`: Metadata in the Pod definition.

### Creating Services

Upon creating a `Service`, the `EndpointSlice controller` creates a corresponding `EndpointSlice` object, & k8s begins monitoring for `Pods` matching the Service's `label selector`.

#### Endpoints vs EndpointSlices

**Endpoints** are the legacy, deprecated object that listed all Pod IPs for a Service in one large resource and existed primarily for backward compatibility.  
**EndpointSlices** are the modern replacement: sharded, scalable objects that Kubernetes actually uses to track which Pods back a Service.  
For debugging and exams, think “EndpointSlices are the source of truth; Endpoints are just a deprecated mirror.”

#### External traffic policy

cluster: routes to all nodes (default)
local: routes only to node-local pods

#### Creation

**Imperative:**

```bash
kubectl run echoserver --image=ealen/echo-server:latest --port=8080
kubectl expose pod echoserver --port=80 --target-port=8080 --name=echo-service
```

**In one step:**

```bash
kubectl run echoserver --image=ealen/echo-server:latest --port=8080 --expose
```

#### Creating Services from Deployments

**Imperative:**

```bash
kubectl create deployment echoserver --image=hashicorp/http-echo:1.0.0 --replicas=5
kubectl expose deployment echoserver --port=80 --target-port=8080
```

**Declarative:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: echoserver
spec:
  selector:
    app: echoserver
  ports:
  - port: 80
    targetPort: 8080
```

#### EndpointSlices

Map Services back to Pod network endpoints.

```bash
kubectl get endpointslices -l app=echoserver
kubectl describe endpointslice <name>
```

### ClusterIP Service (Internal Only)

Testing internal connectivity:

```bash
kubectl run tmp --image=busybox:1.37 --restart=Never -it --rm -- \
  wget -O- <ClusterIP>
```

**DNS Lookup:**

```bash
kubectl run tmp --image=busybox:1.36.1 --restart=Never -it --rm -- \
  wget -O- echoserver.<namespace>.svc.cluster.local
```

### NodePort and LoadBalancer

```bash
kubectl create service nodeport echoserver --tcp=5005:8080
kubectl create service loadbalancer echoserver --tcp=5005:8080
```

## Chapter 18 - Ingresses

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

## Chapter 19 - Gateway API

Successor to Ingress, handles any protocol (L4/L7).

### Core Resources

Gateway API splits the old, monolithic Ingress object into three distinct pieces, based on role:

- **Gateway:** Listener/entry point. (role: cluster operator) -- "An instance of traffic handling infrastructure"
  binds one or more `Addresses` to one or more `Listeners`
  `Listeners` - port + protocol
- **GatewayClass:** Controller definition. (role: infrastructure provider) -- all the software guts of the gateway controller
- **HTTPRoute/GRPCRoute:** Actual mapping/routing rules to backends. (role: application dev)

### Installation

```bash
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml
kubectl get crds | grep gateway
```

### Gateway API Example

#### Kinda goin' through it

1. Install Gateway API CRDs (The "API" definitions)
kubectl apply --server-side -f <https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml>

2. Install a Controller (Envoy Gateway - simple for testing)
helm install eg oci://docker.io/envoyproxy/gateway-hel --version v1.6.1 -n envoy-gateway-system --create-namespace

3. Wait for it to be ready
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available

4. Apply a GatewayClass (simulating the exam environment)
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: my-gateway-class
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
EOF

**1. GatewayClass:**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
```

**2. Gateway:**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: hello-world-gateway
spec:
  gatewayClassName: envoy
  listeners:
  - name: http
    protocol: HTTP
    port: 80
```

**3. HTTPRoute:**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello-world-route
spec:
  parentRefs:
  - name: hello-world-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web
      port: 3000
```

## Chapter 20 - Network Policies

Controls inter-pod communication. Requires a CNI that supports policies (e.g., Calico, Flannel).

Pod isolation:
isolation for egress
ditto ingress

- by default pod is `non-isolated` for `egress`-- all outbound connections allowed
- by default pod is `non-isolated` for `ingress`-- all inbound connections allowed

```For a connection from a source pod to a destination pod to be allowed, both the egress policy on the source pod and the ingress policy on the destination pod need to allow the connection. If either side does not allow the connection, it will not happen.```

**Allow Specific Ingress Example:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-allow
spec:
  podSelector:              # Matches pods **TO WHICH NETWORKPOLICY APPLIES**
    matchLabels:
      app: api
  ingress:
  - from:                   # These guys are allowed to **SEND TO** the pod
    - podSelector:          
        matchLabels:
          app: frontend
```

**Default Deny All:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes: ["Ingress", "Egress"]
```

## Chapter 21 - Troubleshooting Applications

1. **Check Status:** `kubectl get pods`
2. **Events:** `kubectl get events --sort-by='.lastTimestamp'`
3. **Logs:** `kubectl logs <pod-name>`
4. **Interactive Shell:** `kubectl exec -it <pod> -- /bin/sh`
5. **Ephemeral Debugging:** `kubectl debug -it <pod> --image=busybox`
6. **Port Forwarding:** `kubectl port-forward pod/<pod> 8080:80`
7. **Resource Usage:** `kubectl top pod`

## Chapter 22 - Troubleshooting Clusters

**Common Control Plane Components:** `kube-apiserver`, `etcd`, `kube-scheduler`, `core-dns`, `kube-controller-manager`.
**Node Components:** `kubelet`, `kube-proxy`, container runtime.

1. **Cluster Info:** `kubectl cluster-info`
2. **Component Logs:** `kubectl logs <pod-name> -n kube-system`
3. **Kubelet Status:** `systemctl status kubelet` or `journalctl -u kubelet`
4. **Cert Expiration:** `kubeadm certs check-expiration`
5. **Node Description:** `kubectl describe node <name>` (Check for Taints/Pressure).

## From Poulton - Service discovery

Here are two concise summaries of the "meat" of these processes, designed for your notes.

### 1. Service Registration: The "Coordination"

When you apply a `Service` YAML, Kubernetes doesn't just create one object; it triggers a series of background events to build a routing map:

- **The Identity:** The API server creates the **Service** object with a stable **ClusterIP**. This IP is "virtual"—it doesn't belong to a real network interface.
- **The Address Book:** The **EndpointSlice** controller watches for Pods that match the Service’s `selector`. It continuously updates an **EndpointSlice** object with the real, private IPs of all healthy, matching Pods.
- **The Name:** **CoreDNS** watches the API server for new Services. When it sees yours, it automatically creates a DNS record (A and SRV) mapping your Service name to that stable ClusterIP.

### 2. Service Discovery: The "Magic Trap"

Discovery is how an app actually reaches its destination using the information registered above:

- **DNS Resolution:** Your app looks up `my-service`. The kernel’s search domains (configured by the `kubelet`) allow it to find the ClusterIP via the cluster’s internal DNS.
- **The kube-proxy "Trap":** Here is the "mysterious" bit: `kube-proxy` runs on every node and watches both the Service and the EndpointSlice. It programs the **node's kernel** (using IPVS or iptables) with a set of rules.
- **Traffic Routing:** When your app sends a packet to the **ClusterIP**, the kernel sees those `kube-proxy` rules and realizes, "This isn't a real IP; it's a redirect." The kernel then intercepts the packet and transparently rewrites the destination to one of the **real Pod IPs** from the EndpointSlice list before sending it across the network.

---

**Note for your ADHD breakdown:** * **Service** = The Name & stable VIP (The "Phone Number").

- **EndpointSlice** = The list of live Pod IPs (The "Actual People" answering the phone).
- **kube-proxy** = The "Switchboard" inside every node's brain that knows how to connect the Phone Number to a person.

---

## Notes from Hohn's "The Book of Kubernetes"

### Chapter 8 - Overlay Networks

### Chapter 9 - Service and Ingress Networks

kube-proxy configures traffic routing for ClusterIP services using either `iptables` or `IPVS`.

### Chapter 11 - Control Plane and Access Control

API Server-
Scheduler - assigns pods to nodes
Controller manager - does lots-- creating pods for Deployments, monitoring nodes, reacting
Cloud controller manager - interfaces w/ cloud provider to check on nodes and configuration network routing

#### Tokens and tokens

Bootstrap tokens are used to join nodes to the cluster-- to check whether the node is authorized to request a certificate. They have a TTL and can be listed with:

- created with `kubeadm token create`
- kep`t in`kube-system` namespace as a secret
- only have access to CertificateSigningRequests -- prolly only create

#### Service Accounts

### Chapter 12 - Container Runtime

#### The kubelet

Three main config groups: cluster config, container runtime, network config

1. kubelet uses boostrap token to submit a CertificateSigningRequest (CSR) to the API server
2. kubelete downloads the signed cert, stores it in /etc/kubernetes/kubelet.conf -- the kubelet's KUBECONFIG
 stored in /var/lib/kubelet/config.yaml

##### Kubelet container runtime configuration

## TIPS AND TACTICS

### YAML Generation

```bash
kubectl run web-app --image=nginx --dry-run=client -o yaml > pod.yaml
```

# Chapter 15 - Storage

# Chapter 18 - Affinities and devices

#### Pod Anti-Affinity Example

Don't put multiple instances of the same pod on the same node:

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: iperf-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: iperf-server
  template:
    metadata:
      labels:
        app: iperf-server
    spec:
   ➊ affinity:
        podAntiAffinity:
       ➋ requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - iperf-server
         ➌ topologyKey: "kubernetes.io/hostname"
      containers:
      - name: iperf
        image: bookofkubernetes/iperf3:stable
        env:
        - name: IPERF_SERVER
          value: "1"
```

1. `topologyKey`: the node label that the scheduler uses to distinguish between nodes. Most common is `kubernetes.io/hostname`, which means "different physical nodes".

**EVEN BETTER!**

#### Dump existing pod to YAML, strip the cruft

```bash
kubectl get pod log-pod -o yaml | grep -v "creationTimestamp:\|resourceVersion:\|uid:\|status:" > pod.yaml
```

**POSSIBLY SLICKER STILL**

```bash
kubectl get pod log-pod -o yaml | kubectl create --dry-run=client -o yaml -f -
```

Edit pod.yaml - you already have the container block, just duplicate it

#### Quick syntax check without leaving terminal

`kubectl explain pod.spec.containers.volumeMounts --recursive`

### Context and Visibility

- **Switch Namespace:** `kubectl config set-context --current --namespace=<ns>`
- **Validate Labels:** `kubectl get pods --show-labels`
- **Verbosity:** `kubectl get pods -v=6` (shows API calls).

### Execution

- **Container-specific exec:** `kubectl exec <pod> -it -c <container> -- /bin/sh`

# Links

Snapshot etcd:
<https://etcd.io/docs/v3.5/op-guide/recovery/>
