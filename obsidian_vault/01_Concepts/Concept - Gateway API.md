---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Chapter 19 - Gateway API", "Gateway API"]
---

# Concept - Gateway API

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
apiVersion: gateway.[[Topic - Networking|networking]].k8s.io/v1
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

---
**Topics:** [[Topic - Networking]], [[Topic - Security]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
