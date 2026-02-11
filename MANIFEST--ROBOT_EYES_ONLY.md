# Drill Manifest -- ROBOT EYES ONLY

This document tracks generated drills against the CKA curriculum to ensure novelty and coverage.

## Storage

- **Drill**: `storage/resize-persistent-volume`
  - **Curriculum**: Implement storage classes and dynamic volume provisioning (specifically expansion)
  - **Description**: Expand an existing PVC and verify the filesystem resize (simulated or real if storage class allows).

## Workloads and Scheduling

- **Drill**: `workloads/multi-container-logging-sidecar`
  - **Curriculum**: Understand the primitives used to create robust, self-healing, application deployments (Sidecar pattern)
  - **Description**: Add a sidecar container to an existing pod that reads logs from a shared emptyDir volume.
- **Drill**: `workloads/node-affinity-required`
  - **Curriculum**: Configure Pod admission and scheduling (node affinity)
  - **Description**: Schedule a pod that MUST run on a node with label `disk=ssd`.

## Servicing and Networking

- **Drill**: `networking/namespace-isolation-policy`
  - **Curriculum**: Define and enforce Network Policies
  - **Description**: Create a NetworkPolicy that denies all ingress traffic from other namespaces, but allows traffic from within the same namespace.
- **Drill**: `networking/expose-deployment-nodeport`
  - **Curriculum**: Use ClusterIP, NodePort, LoadBalancer service types
  - **Description**: Expose an existing Nginx deployment on a specific NodePort (e.g. 30080).

## Troubleshooting

- **Drill**: `troubleshooting/pod-pending-resource-limits`
  - **Curriculum**: Troubleshoot cluster components (Scheduler decisions based on resources)
  - **Description**: A pod is Pending. User must identify that requests exceed available node cp/mem and fix it (lower requests).
- **Drill**: `troubleshooting/broken-service-selector`
  - **Curriculum**: Troubleshoot services and networking
  - **Description**: A Service is created but no Endpoints are populated. User must fix the selector to match Pod labels.
- **Drill**: `troubleshooting/crashloop-wrong-command`
  - **Curriculum**: Manage and evaluate container output streams
  - **Description**: Pod is CrashLoopBackOff. logs show "command not found". User fixes the `command` or `args`.

## Cluster Architecture, Installation and Configuration

- **Drill**: `cluster/etcd-snapshot-backup`
  - **Curriculum**: Manage the lifecycle of Kubernetes clusters (Backup/Restore)
  - **Description**: Execute an etcdctl snapshot save command to back up the cluster state.
- **Drill**: `security/restrict-service-account`
  - **Curriculum**: Manage role based access control (RBAC)
  - **Description**: Create a Role and RoleBinding to allow a ServiceAccount to only `create` Pods in namespace `web`.
- **Drill**: `cluster/clusterrole-readonly`
  - **Curriculum**: Manage role based access control (RBAC)
  - **Description**: Create ClusterRole with read-only permissions across all namespaces for a monitoring ServiceAccount.

---

## New Drills (2026-01-06)

### Storage

- **Drill**: `storage/pvc-access-modes`
  - **Curriculum**: Configure volume types, access modes and reclaim policies
  - **Description**: Create a PVC with ReadOnlyMany or ReadWriteMany access mode for multi-pod mounting.
- **Drill**: `storage/pv-reclaim-policy`
  - **Curriculum**: Configure volume types, access modes and reclaim policies
  - **Description**: Change a PersistentVolume's reclaim policy from Delete to Retain.

### Workloads and Scheduling

- **Drill**: `workloads/rolling-update-strategy`
  - **Curriculum**: Understand application deployments and how to perform rolling update and rollbacks
  - **Description**: Update deployment image with specific maxUnavailable and maxSurge rolling update parameters.
- **Drill**: `workloads/secret-configuration`
  - **Curriculum**: Use ConfigMaps and Secrets to configure applications
  - **Description**: Configure pod to use secrets as both environment variables and mounted files.
- **Drill**: `workloads/resource-quota-limits`
  - **Curriculum**: Configure Pod admission and scheduling (limits)
  - **Description**: Create ResourceQuota and LimitRange to enforce namespace resource constraints.

### Servicing and Networking

- **Drill**: `networking/headless-service`
  - **Curriculum**: Use ClusterIP, NodePort, LoadBalancer service types and endpoints
  - **Description**: Create headless service for StatefulSet with direct pod DNS resolution.
- **Drill**: `networking/gateway-weighted-routing`
  - **Curriculum**: Use the Gateway API to manage Ingress traffic
  - **Description**: Configure Gateway API HTTPRoute with weighted traffic split (80/20 canary deployment).

### Troubleshooting

- **Drill**: `troubleshooting/node-disk-pressure`
  - **Curriculum**: Troubleshoot clusters and nodes
  - **Description**: Identify and resolve node NotReady condition caused by disk pressure.
- **Drill**: `troubleshooting/coredns-failure`
  - **Curriculum**: Troubleshoot services and networking / Understand and use CoreDNS
  - **Description**: Diagnose and fix CoreDNS issues preventing DNS resolution cluster-wide.

---

## New Drills (2026-01-07)

### Workloads and Scheduling

- **Drill**: `workloads/secret-file-permissions`
  - **Curriculum**: Use ConfigMaps and Secrets to configure applications
  - **Description**: Mount secrets as files with restrictive permissions (0400) for secure credential access.
- **Drill**: `workloads/taint-tolerations`
  - **Curriculum**: Configure Pod admission and scheduling (taints and tolerations)
  - **Description**: Schedule a pod on a tainted node using appropriate tolerations to overcome NoSchedule effect.

### Servicing and Networking

- **Drill**: `networking/ingress-tls`
  - **Curriculum**: Know how to use Ingress controllers and Ingress resources
  - **Description**: Configure TLS/HTTPS for an Ingress using a TLS secret and secure host routing.

### Troubleshooting

- **Drill**: `troubleshooting/imagepullbackoff-secret`
  - **Curriculum**: Troubleshoot cluster components / Manage and evaluate container output streams
  - **Description**: Resolve ImagePullBackOff by creating docker-registry secret or fixing image reference.

### Cluster Architecture, Installation and Configuration

- **Drill**: `cluster/certificate-expiration-check`
  - **Curriculum**: Manage the lifecycle of Kubernetes clusters (Certificate management)
  - **Description**: Use kubeadm to check cluster certificate expiration dates and understand renewal requirements.

---

## New Drills (2026-01-07) - Batch 2

### Networking

- **Drill**: `networking/service-loadbalancer`
  - **Curriculum**: Use ClusterIP, NodePort, LoadBalancer service types
  - **Description**: Expose a deployment using `type: LoadBalancer` and verify external IP allocation (MetalLB).
- **Drill**: `networking/restrict-egress-traffic`
  - **Curriculum**: Define and enforce Network Policies
  - **Description**: Create a strict egress NetworkPolicy that only allows DNS traffic (Cilium).

### Storage

- **Drill**: `storage/statefulset-local-path`
  - **Curriculum**: Implement storage classes and dynamic volume provisioning
  - **Description**: Deploy a StatefulSet using `volumeClaimTemplates` with `local-path` storage class.

### Workloads and Scheduling

- **Drill**: `workloads/hpa-autoscale`
  - **Curriculum**: Configure workload autoscaling
  - **Description**: Configure HorizontalPodAutoscaler to scale a deployment based on CPU utilization (Metrics Server).

### Troubleshooting

- **Drill**: `troubleshooting/pvc-storage-class-mismatch`
  - **Curriculum**: Troubleshoot cluster components / storage
  - **Description**: Fix a pending Pod by correcting a PVC that requests a non-existent StorageClass to use `local-path`.

---

## New Drills (2026-01-08) - Helm, Kustomize & CKA Scenarios

### Cluster Architecture, Installation and Configuration

- **Drill**: `cluster/helm-install-chart`
  - **Curriculum**: Use Helm and Kustomize to install cluster components
  - **Description**: Install a local Helm chart with specific release name and values override.
- **Drill**: `cluster/helm-rollback`
  - **Curriculum**: Use Helm and Kustomize to install cluster components (Lifecycle)
  - **Description**: Fix a failed release by performing a Helm rollback to the previous revision.
- **Drill**: `cluster/helm-repo-management`
  - **Curriculum**: Use Helm and Kustomize to install cluster components
  - **Description**: Add the Bitnami repo and install a chart from it.
- **Drill**: `cluster/kustomize-base-overlay`
  - **Curriculum**: Use Helm and Kustomize to install cluster components
  - **Description**: Create and apply a Kustomize overlay for a specific environment (prod) adjusting replicas and labels.
- **Drill**: `cluster/kustomize-patches`
  - **Curriculum**: Use Helm and Kustomize to install cluster components
  - **Description**: Apply a strategic merge patch via `kustomization.yaml` to modify container commands.
- **Drill**: `cluster/kubeconfig-extract`
  - **Curriculum**: Manage role based access control (RBAC) / Cluster Lifecycle
  - **Description**: Extract and decode client certificates from `kubeconfig` for external use (inspired by Killer.sh).

### Troubleshooting

- **Drill**: `troubleshooting/high-cpu-pod`
  - **Curriculum**: Monitor cluster and application resource usage
  - **Description**: Identify the highest CPU consuming pod in a namespace using `kubectl top`.
- **Drill**: `troubleshooting/hpa-missing-metrics`
  - **Curriculum**: Configure workload autoscaling / Monitor resource usage
  - **Description**: Fix a broken HPA by adding missing resource requests to the target Deployment.

### Servicing and Networking

- **Drill**: `networking/httproute-header-match`
  - **Curriculum**: Use the Gateway API to manage Ingress traffic
  - **Description**: Route traffic to different services based on `User-Agent` header using Gateway API HTTPRoute.

---

## New Drills (2026-01-08) - ConfigMap & Secret Patterns

### Workloads and Scheduling

- **Drill**: `workloads/immutable-configmap`
  - **Curriculum**: Use ConfigMaps and Secrets to configure applications
  - **Description**: Configure a ConfigMap key as `immutable: true` to prevent updates and optimize Kubelet watching.
- **Drill**: `workloads/env-from-aggregation`
  - **Curriculum**: Use ConfigMaps and Secrets to configure applications
  - **Description**: Aggregate environment variables from both a ConfigMap and a Secret, applying a prefix (`CONF_`) to the ConfigMap variables.
- **Drill**: `workloads/projected-volume-keys`
  - **Curriculum**: Use ConfigMaps and Secrets to configure applications
  - **Description**: Mount specific ConfigMap keys to custom file paths (projection) rather than mounting the entire directory.

---

## New Drills (2026-01-11) - Advanced Workloads & Networking

### Networking

- **Drill**: `networking/gateway-path-routing`
  - **Curriculum**: Use the Gateway API to manage Ingress traffic
  - **Description**: Route traffic to different services based on URL path prefixes (/v1, /v2) using Gateway API HTTPRoute.

### Troubleshooting

- **Drill**: `troubleshooting/crictl-inspection`
  - **Curriculum**: Troubleshoot cluster components / nodes
  - **Description**: Use `crictl` on a worker node to identify the PID of a specific container and annotate the Pod with it.

### Workloads and Scheduling

- **Drill**: `workloads/init-container-dependency`
  - **Curriculum**: Understand the primitives used to create robust, self-healing, application deployments
  - **Description**: Use an Init Container to wait for a dependent Service to become available before starting the main container.
- **Drill**: `workloads/pod-priority-class`
  - **Curriculum**: Configure Pod admission and scheduling (PriorityClasses)
  - **Description**: Create a high-value PriorityClass and assign it to a Pod to ensure scheduling precedence.
- **Drill**: `workloads/security-context-capabilities`
  - **Curriculum**: Configure Pod security context
  - **Description**: Secure a container by dropping ALL capabilities and only adding specific required ones (NET_ADMIN).

### Cluster Architecture, Installation and Configuration

- **Drill**: `cluster/node-maintenance`
  - **Curriculum**: troubleshoot clusters and nodes / drain
  - **Description**: Cordon and drain a node to safely evict pods.

---

## New Drills (2026-01-11) - Batch 2

### Workloads and Scheduling

- **Drill**: `workloads/topology-spread-constraint`
  - **Curriculum**: Configure Pod admission and scheduling (topology spread)
  - **Description**: Ensure pods are distributed evenly across nodes using topologySpreadConstraints.

### Servicing and Networking

- **Drill**: `networking/ingress-fanout`
  - **Curriculum**: Know how to use Ingress controllers and Ingress resources
  - **Description**: Configure path-based routing (fanout) for an Ingress to multiple services.

### Storage

- **Drill**: `storage/storage-class-default`
  - **Curriculum**: Implement storage classes and dynamic volume provisioning
  - **Description**: Create a new StorageClass and set it as the cluster-wide default.

### Troubleshooting

- **Drill**: `troubleshooting/init-container-crash`
  - **Curriculum**: Manage and evaluate container output streams / Troubleshoot applications
  - **Description**: Diagnose and fix a crashing init container that prevents pod startup.

---

## New Drills (CKA-b Coverage)

### Workloads and Scheduling

- **Drill**: `workloads/static-pod-creation`
  - **Curriculum**: Understand the primitives used to create robust, self-healing, application deployments (Static Pods)
  - **Description**: Create a static Pod named `static-web` on the controlplane node by placing a manifest in the kubelet manifest directory.
- **Drill**: `workloads/manual-scheduling`
  - **Curriculum**: Configure Pod admission and scheduling (Manual scheduling)
  - **Description**: Schedule a pod to a specific node *without* using the scheduler (simulate scheduler failure) by setting the `nodeName` field directly.
- **Drill**: `workloads/configured-probes`
  - **Curriculum**: Understand LivenessProbes and ReadinessProbes
  - **Description**: Configure a Pod with a LivenessProbe (exec command) and a ReadinessProbe (HTTP check) to ensure traffic only hits healthy pods.
- **Drill**: `workloads/job-with-pvc`
  - **Curriculum**: Understand workload & storage (Jobs)
  - **Description**: Create a Job that mounts a PVC, writes a log file, and completes successfully.

### Troubleshooting

- **Drill**: `troubleshooting/broken-kubelet-config`
  - **Curriculum**: Troubleshoot cluster components (Kubelet)
  - **Description**: The Kubelet is stopped. Identify the misconfigured flag or path in `/var/lib/kubelet/config.yaml` or systemd service and restart it.

### Servicing and Networking

- **Drill**: `networking/dns-record-verification`
  - **Curriculum**: Understand and use CoreDNS
  - **Description**: Launch a temporary pod to verify DNS resolution for a Service, a Headless Service, and an external FQDN.

---

## New Drills (Killer.sh Difficulty)

### Cluster Architecture, Installation and Configuration

- **Drill**: `security/csr-user-auth`
  - **Curriculum**: Manage role based access control (RBAC)
  - **Description**: Generate a CSR for a new user `jane`, approve the certificate via API, and configure a kubeconfig context.
- **Drill**: `cluster/jsonpath-complex-query`
  - **Curriculum**: Monitor cluster and application resource resource usage
  - **Description**: Use JSONPath and custom-columns to extract and sort Pod information (Name, Node) into a specific file format.

### Workloads and Scheduling

- **Drill**: `workloads/pod-affinity-required`
  - **Curriculum**: Configure Pod admission and scheduling (Affinity)
  - **Description**: Configure Inter-pod Affinity so that a Deployment's pods are only scheduled on nodes running a specific "anchor" pod.
- **Drill**: `workloads/daemonset-controlplane-toleration`
  - **Curriculum**: Configure Pod admission and scheduling (Tolerations)
  - **Description**: Deploy a DaemonSet that successfully schedules pods on the control-plane node by tolerating the `node-role.kubernetes.io/control-plane` taint.

### Servicing and Networking

- **Drill**: `networking/networkpolicy-namespace-allow`
  - **Curriculum**: Define and enforce Network Policies
  - **Description**: Create a NetworkPolicy that creates a "default deny" firewall, but whitelists traffic from a specific namespace's pods on port 80.

---

## New Drills (Batch 3)

### Workloads and Scheduling

- **Drill**: `workloads/downward-api-pod-info`
  - **Curriculum**: Configure Pod admission and scheduling (Downward API)
  - **Description**: Expose Pod name and namespace as environment variables to the container.
- **Drill**: `workloads/run-as-user-security`
  - **Curriculum**: Configure Pod security context
  - **Description**: Configure a Pod to run with specific User ID and Group ID using `securityContext`.
- **Drill**: `workloads/cronjob-history-limits`
  - **Curriculum**: Understand workload & storage (CronJobs)
  - **Description**: configure `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` on a CronJob.

### Servicing and Networking

- **Drill**: `networking/service-externalname`
  - **Curriculum**: Use ClusterIP, NodePort, LoadBalancer service types (ExternalName)
  - **Description**: Map a Service to an external DNS name using `ExternalName` type.
- **Drill**: `networking/service-nodeport-static`
  - **Curriculum**: Use ClusterIP, NodePort, LoadBalancer service types
  - **Description**: Expose a Deployment via a NodePort Service with a statically defined node port (e.g., 30080).

### Troubleshooting

- **Drill**: `troubleshooting/pod-stuck-terminating`
  - **Curriculum**: Troubleshoot clusters and nodes / Finalizers
  - **Description**: Force delete a Pod stuck in `Terminating` state due to a stuck finalizer.
- **Drill**: `troubleshooting/deployment-image-patch`
  - **Curriculum**: Understand application deployments
  - **Description**: Update a Deployment's image using imperative commands (`kubectl set image`) without editing YAML.

### Cluster Architecture, Installation and Configuration

- **Drill**: `cluster/etcd-data-directory`
  - **Curriculum**: Troubleshoot cluster components
  - **Description**: Inspect the running etcd process to identify its data directory location.
- **Drill**: `cluster/pod-manifest-extraction`
  - **Curriculum**: Manage the lifecycle of Kubernetes clusters
  - **Description**: Extract the clean YAML manifest of a running static pod (e.g., api-server) for backup/restore purposes.

### Storage

- **Drill**: `storage/manual-hostpath-pv`
  - **Curriculum**: Manage persistent volumes and persistent volume claims
  - **Description**: Manually create a `hostPath` PV and a PVC that specifically binds to it (mocking static provisioning).

---

## New Drills (2026-01-23) - Killer.sh Style Final Prep

### Troubleshooting

- **Drill**: `troubleshooting/etcd-restore-snapshot`
  - **Curriculum**: Manage the lifecycle of Kubernetes clusters (Backup/Restore)
  - **Description**: Restore etcd from a snapshot to a new data directory and update the static pod manifest. (Killer.sh CKA-b Q7 style)
- **Drill**: `troubleshooting/qos-termination-order`
  - **Curriculum**: Monitor cluster and application resource usage / Troubleshoot clusters
  - **Description**: Identify pods with BestEffort QoS that would be evicted first under resource pressure. (Killer.sh CKA-a Q4 style)

### Servicing and Networking

- **Drill**: `networking/egress-policy-database`
  - **Curriculum**: Define and enforce Network Policies
  - **Description**: Create egress NetworkPolicy allowing only DNS and database access while blocking other traffic. (Killer.sh CKA-a Q15 style)
- **Drill**: `networking/gateway-useragent-routing`
  - **Curriculum**: Use the Gateway API to manage Ingress traffic
  - **Description**: Route traffic based on User-Agent header using Gateway API HTTPRoute. (Killer.sh CKA-a Q13 style)
- **Drill**: `networking/coredns-custom-domain`
  - **Curriculum**: Understand and use CoreDNS
  - **Description**: Add custom domain suffix to CoreDNS so services resolve via both cluster.local and custom domain. (Killer.sh CKA-a Q16 style)

### Cluster Architecture, Installation and Configuration

- **Drill**: `security/serviceaccount-api-query`
  - **Curriculum**: Manage role based access control (RBAC)
  - **Description**: Use a ServiceAccount from within a Pod to query the Kubernetes API and retrieve secrets. (Killer.sh CKA-a Q9 style)

### Storage

- **Drill**: `storage/job-with-retained-pvc`
  - **Curriculum**: Implement storage classes and dynamic volume provisioning / Configure reclaim policies
  - **Description**: Create StorageClass with Retain policy, PVC, and Job that persists backup data. (Killer.sh CKA-b Q10 style)

### Workloads and Scheduling

- **Drill**: `workloads/daemonset-all-nodes`
  - **Curriculum**: Configure Pod admission and scheduling (tolerations) / Understand DaemonSets
  - **Description**: Deploy DaemonSet on all nodes including control plane by tolerating taints. (Killer.sh CKA-a Q11 style)

---

## New Drills (2026-01-25) - CKA Final Polish

### Networking

- **Drill**: `networking/gateway-header-route`
  - **Curriculum**: Use the Gateway API to manage Ingress traffic
  - **Description**: Route traffic to different services based on the "Version" header using Gateway API HTTPRoute. (CKA-a Q13 style variant)
- **Drill**: `networking/deny-all-policy`
  - **Curriculum**: Define and enforce Network Policies
  - **Description**: Implement a default deny ingress policy and allow a specific ingress source. (CKA-a Q15 style)

### Troubleshooting

- **Drill**: `troubleshooting/crash-config`
  - **Curriculum**: troubleshoot applications / manage and evaluate container output streams
  - **Description**: Fix a Deployment in CrashLoopBackOff caused by missing environment variable configuration from a Secret.

### Storage

- **Drill**: `storage/pvc-migration`
  - **Curriculum**: Manage persistent volumes and persistent volume claims
  - **Description**: Migrate data from a small PVC to a larger PVC and preserve data integrity manually.

### Cluster Architecture, Installation and Configuration

- **Drill**: `rbac/pod-viewer`
  - **Curriculum**: Manage role based access control (RBAC)
  - **Description**: Create Role and RoleBinding to allow strictly listing/getting Pods. (CKA-a Q10 style)
- **Drill**: `cluster/etcd-backup`
  - **Curriculum**: Manage the lifecycle of Kubernetes clusters
  - **Description**: Perform an etcd snapshot backup command on the control plane. (CKA-b Q7 style)

### Workloads and Scheduling

- **Drill**: `scheduling/taint-toleration`
  - **Curriculum**: Configure Pod admission and scheduling (Taints/Tolerations)
  - **Description**: Schedule a specific pod to the control plane without removing the existing node taint (Node Affinity/Toleration). (CKA-a Q11 style)
- **Drill**: `workloads/sidecar-adapter`
  - **Curriculum**: Understand the primitives used to create robust, self-healing, application deployments (Sidecar/Logging)
  - **Description**: Add a sidecar container to an existing Deployment to stream logs from a volume to stdout.

---

## New Drills (2026-01-31) - Last Mile CKA Prep

### Workloads and Scheduling

- **Drill**: `workloads/logging-sidecar`
  - **Curriculum**: Understand the primitives used to create robust, self-healing, application deployments (Sidecar/Logging)
  - **Description**: Add a sidecar container to validly stream log files from a volume to stdout.
- **Drill**: `workloads/ds-control-plane`
  - **Curriculum**: Configure Pod admission and scheduling (Tolerations)
  - **Description**: Deploy a DaemonSet that runs on all nodes including the control plane.
- **Drill**: `scheduling/exclusive-node-taint`
  - **Curriculum**: Configure Pod admission and scheduling (Taints/Tolerations/Affinity)
  - **Description**: Schedule a pod on a specific tainted node using both Tolerations and NodeAffinity.

### Servicing and Networking

- **Drill**: `networking/netpol-namespace-isolation`
  - **Curriculum**: Define and enforce Network Policies
  - **Description**: Isolate a namespace from ingress traffic except for a trusted source using NetworkPolicy.
- **Drill**: `networking/gateway-api-path`
  - **Curriculum**: Use the Gateway API to manage Ingress traffic
  - **Description**: Route traffic to a service using Gateway API HTTPRoute path matching.

### Storage

- **Drill**: `storage/hostpath-pv-pvc`
  - **Curriculum**: Manage persistent volumes and persistent volume claims
  - **Description**: Manually create and bind a PV and PVC using `volumeName` binding.

### Security/RBAC

- **Drill**: `rbac/sa-restricted-viewer`
  - **Curriculum**: Manage role based access control (RBAC)
  - **Description**: Create a ServiceAccount with limited Role access to specific resources (get/list).

### Troubleshooting

- **Drill**: `troubleshooting/service-endpoint-debug`
  - **Curriculum**: Troubleshoot services and networking
  - **Description**: Diagnose and fix a Service selector mismatch preventing endpoint creation.

---

## New Drills (2026-02-01) - Killer.sh Final Polish

### Workloads and Scheduling

- **Drill**: `workloads/hpa-scale-behavior`
  - **Curriculum**: Configure workload autoscaling
  - **Description**: Configure v2 HPA scale-down stabilization window to prevent thrashing.
- **Drill**: `workloads/canary-manual`
  - **Curriculum**: Understand application deployments
  - **Description**: Perform a manual canary rollout by manipulating replica counts of two deployments sharing a Service.
- **Drill**: `workloads/deployment-revision-history`
  - **Curriculum**: Understand application deployments
  - **Description**: Limit the number of old ReplicaSets retained by a Deployment (revisionHistoryLimit).

### Servicing and Networking

- **Drill**: `networking/gateway-tls`
  - **Curriculum**: Use the Gateway API to manage Ingress traffic
  - **Description**: Configure a Gateway with a TLS listener using a provided secret.
- **Drill**: `networking/headless-dns`
  - **Curriculum**: Use ClusterIP, NodePort, LoadBalancer service types
  - **Description**: Create a headless service (ClusterIP: None) to allow direct pod DNS resolution.

### Scheduling

- **Drill**: `scheduling/pod-anti-affinity`
  - **Curriculum**: Configure Pod admission and scheduling (Affinity)
  - **Description**: Use `podAntiAffinity` to ensure high availability by forcing pods of a deployment onto different nodes.

### Troubleshooting

- **Drill**: `troubleshooting/liveness-timeout`
  - **Curriculum**: Understand LivenessProbes and ReadinessProbes
  - **Description**: Fix a crashing pod by adjusting the Liveness Probe `initialDelaySeconds` to accommodate slow startup.

### Cluster Architecture, Installation and Configuration

- **Drill**: `rbac/role-aggregation`
  - **Curriculum**: Manage role based access control (RBAC)
  - **Description**: Create a ClusterRole that aggregates permissions from other roles using labels (`aggregationRule`).

## New Drills (2026-02-02) - CKA Killer Exam Prep

### Workloads and Scheduling

- **Drill**: `workloads/hpa-behavior`
  - **Curriculum**: Configure workload autoscaling
  - **Description**: Configure HPA v2 with specific scaleDown stabilization window policy for a deployment missing resource requests.
- **Drill**: `workloads/sidecar-logging`
  - **Curriculum**: Understand the primitives used to create robust, self-healing, application deployments
  - **Description**: Implement a sidecar container to stream logs from a file in a shared volume to stdout.

### Servicing and Networking

- **Drill**: `networking/ingress-resource`
  - **Curriculum**: Know how to use Ingress controllers and Ingress resources
  - **Description**: Create a v1 Ingress resource mapping multiple paths to different services with host-based routing.

### Security

- **Drill**: `security/rbac-pod-creator`
  - **Curriculum**: Manage role based access control (RBAC)
  - **Description**: create a ServiceAccount with limited permissions (create/get/list pods only) and verify with auth can-i.

### Troubleshooting

- **Drill**: `troubleshooting/crashloop-config-mismatch`
  - **Curriculum**: Troubleshoot cluster components / application configuration
  - **Description**: Diagnose a CrashLoopBackOff caused by a missing ConfigMap key referenced by envFrom, and fix it.
- **Drill**: `cluster/crictl-investigate`
  - **Curriculum**: Troubleshoot clusters and nodes / Container Runtime Interface
  - **Description**: Use crictl on the node to identify the runtime ID of a specific container.

---

## New Drills (2026-02-05)

### Workloads and Scheduling

- **Drill**: `workloads/pdb-drain-protection`
  - **Curriculum**: Understand the primitives used to create robust, self-healing, application deployments + Manage the lifecycle of Kubernetes clusters
  - **Description**: Create a PodDisruptionBudget for a Deployment ensuring minimum availability during voluntary disruptions. Write allowed disruptions count.

### Cluster Architecture, Installation and Configuration

- **Drill**: `cluster/controlplane-component-audit`
  - **Curriculum**: Create and manage Kubernetes clusters using kubeadm + Understand extension interfaces (CNI, CSI, CRI)
  - **Description**: Investigate and document how each controlplane component is installed (process, static-pod, or pod) including DNS name identification. Killer.sh CKA-b Q8 style.
- **Drill**: `cluster/kustomize-hpa-overlay`
  - **Curriculum**: Use Helm and Kustomize to install cluster components + Configure workload autoscaling
  - **Description**: Remove legacy ConfigMap from Kustomize base, create staging/prod overlays with HPA at different configurations, apply both. Killer.sh CKA-a Q5 style.

### Troubleshooting

- **Drill**: `troubleshooting/cluster-info-investigation`
  - **Curriculum**: Troubleshoot clusters and nodes + Understand connectivity between Pods + Understand extension interfaces (CNI)
  - **Description**: Answer 5 cluster architecture questions: controlplane/worker node count, Service CIDR, CNI plugin + config path, static pod suffix. Killer.sh CKA-b Q14 style.
- **Drill**: `troubleshooting/event-log-forensics`
  - **Curriculum**: Manage and evaluate container output streams + Troubleshoot cluster components
  - **Description**: Write a kubectl events script (sorted, all-namespaces), capture pod lifecycle events after deletion, identify restart policy. Killer.sh CKA-b Q15 style.
- **Drill**: `troubleshooting/multi-container-log-debug`
  - **Curriculum**: Manage and evaluate container output streams + Troubleshoot cluster components
  - **Description**: Investigate a 3-container pod with one CrashLoopBackOff container, identify it, capture its error from logs (--previous), and fix the pod to 3/3 ready.

---

## New Drills (2026-02-08) - CKA Killer Final

### Security

- **Drill**: `security/serviceaccount-no-token`
  - **Curriculum**: Manage role based access control (RBAC) / Configure Pod security context
  - **Description**: Create a ServiceAccount that does *not* automatically mount its token, and a Pod that uses it.

### Networking

- **Drill**: `networking/netpol-named-port`
  - **Curriculum**: Define and enforce Network Policies
  - **Description**: Restrict ingress traffic to a Pod using a specific named port in a NetworkPolicy.

### Workloads and Scheduling

- **Drill**: `workloads/startup-probe`
  - **Curriculum**: Understand LivenessProbes, ReadinessProbes and StartupProbes
  - **Description**: Configure a Startup Probe for a slow-starting legacy application to prevent premature killing by liveness probe.
- **Drill**: `workloads/job-parallelism`
  - **Curriculum**: Understand workload & storage (Jobs)
  - **Description**: Create a Job that runs multiple Pods in parallel to complete a set of tasks.
- **Drill**: `scheduling/node-affinity-soft`
  - **Curriculum**: Configure Pod admission and scheduling
  - **Description**: Schedule a pod that *prefers* to run on a specific node, but can run elsewhere if necessary (preferredDuringSchedulingIgnoredDuringExecution).

### Troubleshooting

- **Drill**: `troubleshooting/scheduler-crash`
  - **Curriculum**: Troubleshoot cluster components
  - **Description**: Diagnose why new Pods are remaining in the `Pending` state (scheduler failure) and fix the underlying issue.
