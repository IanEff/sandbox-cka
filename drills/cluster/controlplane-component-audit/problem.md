# Controlplane Component Audit

You need to investigate how the controlplane components are managed in this kubeadm cluster and document your findings.

Your tasks:

1. Determine how each of the following components is started/installed:
   - kubelet
   - kube-apiserver
   - kube-scheduler
   - kube-controller-manager
   - etcd
   - dns (also identify its name)

2. Write your findings into `/home/vagrant/controlplane-components.txt` in this **exact** format:

```
kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: [TYPE]
dns: [TYPE] [NAME]
```

Choices for `[TYPE]` are: `process`, `static-pod`, `pod`

## Information

- Static pods are managed directly by the kubelet from manifest files (check `/etc/kubernetes/manifests/`)
- Regular pods are managed by the API server via Deployments, DaemonSets, etc.
- Processes run as system services (e.g., managed by systemd)
- Use `systemctl`, `kubectl`, and the filesystem to investigate


## Validation

Verify your findings file matches the required format:
```bash
cat /home/vagrant/controlplane-components.txt
```
