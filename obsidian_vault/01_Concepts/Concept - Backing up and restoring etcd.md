---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Backing up and restoring etcd", "Chapter 5 - Backing up and restoring etcd"]
---

# Concept - Backing up and restoring etcd

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

---
**Topics:** [[Topic - Architecture]], [[Topic - Networking]], [[Topic - Security]], [[Topic - Storage]], [[Topic - Tooling]], [[Topic - Workloads]]
