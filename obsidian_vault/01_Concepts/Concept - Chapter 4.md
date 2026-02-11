---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Chapter 4"]
---

# Concept - Chapter 4

Fucking vagrant. Use `cloud-image/ubuntu-24.04`.

### Speed-ups: local pull-through caches (OrbStack)

This repo can optionally use a **single local cache container** (runs in OrbStack with host [[Topic - Networking|networking]]) to reduce repeated downloads across reprovisioning:

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

- **Drain control plane node (evict [[Topic - Workloads|workloads]]):**

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

---
**Topics:** [[Topic - Architecture]], [[Topic - Networking]], [[Topic - Security]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
