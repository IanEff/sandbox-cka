# NetworkPolicy with Named Ports

## Objective
Restrict ingress traffic to a Pod using a specific named port in a NetworkPolicy.

## Instructions
1.  Create a Namespace named `netpol-demo`.
2.  Create a Pod named `backend` in the `netpol-demo` namespace.
    *   Image: `nginx:alpine`
    *   Label: `app=backend`
    *   Expose port 80 with the name `http-metrics`.
3.  Create a NetworkPolicy named `allow-metrics-only` in the `netpol-demo` namespace.
    *   Apply it to the `backend` Pod.
    *   Allow Ingress traffic **ONLY** to the port named `http-metrics`.
    *   Deny all other ingress traffic to the `backend` Pod.

## Verification
*   Traffic to `backend` on port 80 (renamed to `http-metrics`) from another pod in the same namespace should be **ALLOWED**.
*   Traffic to any other port on `backend` should be **DENIED** (implicitly, or explicitly if tested).
