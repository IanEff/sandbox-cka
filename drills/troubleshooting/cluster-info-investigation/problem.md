# Cluster Information Investigation

You need to investigate various aspects of the cluster architecture and network configuration.

Answer the following questions and write your findings into `/home/vagrant/cluster-info.txt` in this **exact** format:

```
1: [number of controlplane nodes]
2: [number of worker nodes]
3: [Service CIDR]
4: [CNI plugin name] [path to CNI config file]
5: [static pod suffix for this node]
```

### Example

```
1: 1
2: 2
3: 10.96.0.0/12
4: calico /etc/cni/net.d/10-calico.conflist
5: -cka1234
```

## Information

- The Service CIDR is configured as a flag in the kube-apiserver manifest
- CNI configuration typically lives in `/etc/cni/net.d/`
- Static pod names have a suffix based on the node hostname
- Use `kubectl`, apiserver manifest files, and system configuration to find answers
- Worker nodes are nodes **without** the `node-role.kubernetes.io/control-plane` label


## Validation

Verify the content of your investigation file:
```bash
cat /home/vagrant/cluster-info.txt
```
Compare against actual cluster info:
```bash
kubectl get nodes
grep service-cluster-ip-range /etc/kubernetes/manifests/kube-apiserver.yaml
ls /etc/cni/net.d/
```
