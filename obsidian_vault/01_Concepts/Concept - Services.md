---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Chapter 17 - Services", "Services"]
---

# Concept - Services

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

---
**Topics:** [[Topic - Architecture]], [[Topic - Networking]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
