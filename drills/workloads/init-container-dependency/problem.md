# Drill: Init Container Dependency

## Question

**Context:**
You have a workload that fails to start because a dependent service doesn't exist yet.

**Task:**

1. Create a Pod named `web-wait` in the `default` namespace.
    * Image: `nginx`
    * It should contain an **Init Container** (use image `busybox`).
    * The Init Container should loop/wait until it can successfully resolve or connect to the Service `mydb.default.svc.cluster.local`.
        * Command hint: `until nslookup mydb...`
2. Observe that the Pod stays in `Init` status because the service is missing.
3. **Fix the issue** by creating a Service named `mydb` (Type: `ClusterIP`, Port: `80`).
4. Ensure the `web-wait` Pod transitions to `Running` state.

## Hints

* `initContainers`
* `nslookup` or `nc -z`
