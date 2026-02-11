# Notes on Acing the Certified Kubernetes Administrator Exam

## Chapter 1 - First steps

### Available sites during the test

<https://kubernetes.io/docs/>
<https://kubernetes.io/blog/>
<https://helm.sh/docs>
<https://gateway-api.sigs.k8s.io/>

### Linux Debuggery

sudo journalctl -u kubelet
sudo journalctl -u containerd

systemctl status kubelet
systemctl status containerd

** If kubectl logs fails,
cat /var/log/pods

### Kubectl basics

#### Flavors

```bash
kubectl create      # expects no existing resource
kubectl replace     # deletes and recreates
kubectl apply       # can create or update
```

#### Manual KUBECONFIG flattening proceedure

```bash
export KUBECONFIG=~/Downloads/config2:~/.kube/config
kubectl config view --flatten > ~/.kube/config
```

#### **kubectl autocomplete**

Without this, you're fully fucked:

```bash
apt update && apt install -y bash-completion
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'source /usr/share/bash-completion/bash_completion' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc
```

## Chapter 2 - The cluster

### Components

#### Control plane

- API server
- Controller manager (kubelet?)
- Scheduler
- etcd

##### Taints and tolerances

Control plane nodes have taints:

## Chapter 3 - Identity and Access Management

- Requests from humans mapped to usernames <-- not native
- Machines -> serviceaccounts

Auth->authorization (rbac) ->

## Chapter 5 - Running Applications in Kubernetes

### Deployments

`kubectl create deployment apache --apache httpd:latest --replicas 3`
_neat_:
`kubectl set image deployment apache httpd=httpd:alpine`
`kubectl scale deployment apache --replicas=5`

### Rollout

`spec.strategy`

#### Rollout strategies

When a Deployment is modified,
RollingUpdate := waits for Pods from old ReplicaSet drain as you replace
Recreate := terminates old ReplicaSet Pods before running new ones

#### Application rollouts

`kubectl rollout history deployment apache`

To annotate changes with causes,

`kubectl annotate deployment apache kubernetes.io/change-cause="updated image tag from 2 to alpine"`

#### Rollback

`kubectl rollout undo deployment apache --to-revision=1`

### Exposure

`kubectl expose deploy nginx --name nginx-svc --port 80 --type ClusterIP --dry-run=client -o yaml > nginx-svc.yaml`

### Autoscaling - HorizontalPodAutoscaler

- with CPU utilization on the Deployment,

`kubectl autoscale deployment nginx --cpu=80% --min=2 --max=5`

### Node Maintenance

#### Phase one- kicking the kids out of the pool

1. Cordon off the node
`kubectl cordon ubukubu-node-1`
Cordon makes kubectl patch the Node object:
`spec.unschedulable = true`

2. Drain the node
`kubectl drain ubukubu-node-1 --ignore-daemonsets`
`kubectl drain ubukubu-node-1 --ignore-daemonsets --force`
Client-side orchestration:
    1. ensure node is cordoned
    2. list all pods bound to that node
    3. filter for which pods can/should be evicted
    4. for remaining pods:
        1. request eviction via Eviction API (?)
        2. `wait` until the pod disappears

NOTE: without --ignore-daemonsets, this command will FAIL due to the DaemonSet-managed Pod's underlying ownerReferences

#### Phase 2 - node add

1. On a control plane node:
`kubeadm token create --print-join-command`
You could check to see whether the referenced endpoint is correct, then

2. On the node, add all the crap, then run the join command.

#### Node removal

Method:

1. Cordon/drain
2. Delete
`kubectl delete node ubukubu-node-1`

IF a node is described as "failed," the best way is to remove the node, I guess..?
But if the node's in a halfway state and needs to be basically reset,
`kubeadm reset`

### Helm

Go-formatted templating: {{  .values.name  }}

helm status metrics-app -n helm-ns
helm get manifest -n helm-ns metrics-app

### Kustomize

Create base definitions
./base
    deployment.yaml
    service.yaml
    kustomization.yaml <--+

./base/kustomization.yaml:

```yaml
resources:
  - deployment.yaml
  - service.yaml
```

./overlays/staging/kustomization.yaml:

```yaml
resources:
- ../../base

patches:
- target:
    kind: Deployment
    name: my-app
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
```

NOTE: If the exam asks to **remove** any object from the Kustomize files, you've gotta delete it manually from the cluster.
`kubectl kustomize overlays/staging | kubectl diff -f -`

### Operators and CRDs

#### Installing CRDs via Operator

`kubectl apply -server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.26/releases/cnpg-1.26.1.yaml`

#### Leafing through CRDs

`kubectl api-resources –-api-group=postgresql.cnpg.io`
`kubectl explain clusters.postgresql.cnpg.io`

## Chapter 6 - Cluster communication

IP Ranges in Kube:

Nodes CIDR (Internal-IP) := underlying network connecting nodes to infra; provided by infra
Pod CIDR (Cluster-CIDR) := per-pod IPs; managed by CNI
Service CIDR (Service-Cluster-IP-Range) := managed by API server

... (Actually do the exercise at the beginning of the chapter)...

### CoreDNS

#### FQDNs

Each Service is given a unique FQDN: `<service-name>.<namespace>.svc.cluster.local`
Namespace forms the search domain in `/etc/resolv.conf`:

```/etc/resolv.conf
search cluster.local
search c01383.svc.cluster.local svc.cluster.local cluster.local
nameserver 100.96.0.10
options ndots:5
```

Pods FQDNs built from IP addresses (e.g. `10-244-0=14.default.pod.cluster.local`)

#### Service CIDR

Service CIDRs  - ranges for ClusterIP Services
    - can't be deleted if Services lie on top of 'em

1. `Kubernetes API` chooses a free IP from the `ServiceCIDR` object's range;
2. `kube-proxy` then programs iptables rules to forward traffic for those `ServiceIP`s to the backend `Pod`s
3. `kubelet` - Creates CoreDNS pod & injects its configuration

##### Config files

`kubelet` /var/lib/kubelet/config.yaml
    - includes authentication, health endpoints, **cluster DNS**

/etc/kubernetes/manifests
    - autoprovisioned

##### ConfigMaps

kube-system/coredns

kube-system/kubelet-config

### DNSPolicy (from robot)

dnsPolicy := where DNS comes from
    ClusterFirst (defaualt) := nameserver -> DNS Service IP
        search: <namespace>.svc.cluster.local svc.cluster.local cluster.local
    None := Pod figures it out
    ClusterFirstWithHostNet := Same as ClusterFirst, but blah blah
    dnsConfig := with None or ClusterFirst, will override:
        {nameservers, search, options}
dnsConfig := how DNS is customized

kubelet inspects PodSpec -> generates `/etc/resolv.conf` & injects into Pod's network namespace

## To remember

There _is_ a section on HA control plane configuration.  Just make certain you know it.

_Work from the outside in_
start with get endpoints, then get services, then

**PODS IS IMMUTABLE**

Fixing is a _waste of time._ `delete` and re-`create`

## Editing pods

**CRUFT TO CUT** from the yaml outputted by kubectl --dry-run=client

`metadata.managedFields` :
`metadata.uid`, `metadata.resourceVersion`, `metadata.creationTimeStamp`
`metadata.annotations`
`status`
`spec.nodeName`

"The "CKA-Fast" Vim Sequence: If you open the file in vim, you can delete the managedFields block quickly.

Put cursor on the line managedFields:.

Type d% (delete to matching bracket/block end). Done."
