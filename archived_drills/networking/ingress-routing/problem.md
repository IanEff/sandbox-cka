# Drill: Ingress Routing

Two services `foo-service` (port 8080) and `bar-service` (port 9090) are running in the `default` namespace.

**Task:**
Create an Ingress resource named `example-ingress` that routes traffic as follows:
- Path `/foo` points to `foo-service` on port 8080.
- Path `/bar` points to `bar-service` on port 9090.

**Requirements:**
- Use the Ingress Class `nginx` (or whatever is standard in your cluster, for this drill assume `nginx` exists or just specify the class name 'nginx').
- The Ingress must be in the `default` namespace.
- Use Prefix path matching.
