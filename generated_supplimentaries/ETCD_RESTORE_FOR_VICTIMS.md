# Restoring Etcd: A Guide for Victims of the Official Documentation

So you followed the kubernetes.io guide and your cluster is now a brick. Welcome to the club.

Here is the actual procedure that accounts for the fact that `kubeadm` uses static pods with hardcoded host mounts—a "minor detail" the documentation conveniently glosses over while you're probably hyperventilating during the exam.

## The "Official" Lie

The docs tell you to just "restore to a new directory" and update the `--data-dir` flag in the manifest.

**FALSE.**

If you do *only* this in a default kubeadm setup, the `etcd` container starts writing to an ephemeral overlay filesystem because the `volumeMounts` in the static pod manifest still point to the old host directory.

**The Result:** Your cluster initializes as brand new, runs perfectly, but has total amnesia. You stare at `kubectl get nodes` returning `Forbidden` and question your life choices.

## The Working Procedure (CKA-Safe)

Do not try to edit the `volumeMounts` in the YAML. It's too much typing, and you'll mess up the indentation. Instead, trick the pod.

### 1. Perform the Restore

Run the standard restore command, but target a *temporary* location.

```bash
# Assuming you have a snapshot at /tmp/snapshot.db
ETCDCTL_API=3 etcdutl snapshot restore /tmp/snapshot.db \
  --data-dir /var/lib/etcd-restored
```

### 2. The Switcheroo (The Step They Don't Mention)

Instead of fighting with complex YAML volume mounts, swap the directories on the host. This treats the static pod config as immutable and changes the reality underneath it.

```bash
# Move the broken/old data aside (backup the backup plan)
sudo mv /var/lib/etcd /var/lib/etcd.busted

# Move the restored data to the throne
sudo mv /var/lib/etcd-restored /var/lib/etcd
```

Now, the existing `etcd.yaml` volume mounts are valid again, but they point to your restored data.

### 3. The "Have You Tried Turning It Off And On Again?" (Critical)

The API Server is likely clinging to a dead connection or is confused because the new Etcd cluster has a different UUID than the one it was talking to 5 minutes ago. You **MUST** restart it.

The official docs say "stop all API server instances," but don't tell you how. In a static pod world, `kubectl delete pod` often doesn't cut it fast enough.

**The "Nuclear" Option (Guaranteed to work):**

```bash
# 1. Temporarily banish the API server manifest
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/

# 2. Watch the pods die (wait ~20-30 seconds)
# Verify with: crictl ps | grep apiserver

# 3. Bring it back from exile
sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
```

### Summary for the Exam

1. **Restore** content to `/var/lib/etcd-new`.
2. **Swap** dirs: `mv old back`; `mv new old`.
3. **Bounce** the API Server manifest.
4. **Profit.**

Don't let the docs gaslight you.
