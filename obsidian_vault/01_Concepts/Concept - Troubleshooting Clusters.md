---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Troubleshooting Clusters", "Chapter 22 - Troubleshooting Clusters"]
---

# Concept - [[Topic - Troubleshooting|Troubleshooting]] Clusters

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
- **The Name:** **CoreDNS** watches the API server for new [[Concept - Services|Services]]. When it sees yours, it automatically creates a DNS record (A and SRV) mapping your Service name to that stable ClusterIP.

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

## TIPS AND TACTICS

### YAML Generation

```bash
kubectl run web-app --image=nginx --dry-run=client -o yaml > pod.yaml
```

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

---
**Topics:** [[Topic - Architecture]], [[Topic - Networking]], [[Topic - Security]], [[Topic - Storage]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
