# Service LoadBalancer (MetalLB)

**Drill Goal:** Expose a deployment using a LoadBalancer service and verify IP assignment.

## Problem

1.  Create a deployment named `lb-app` in the `default` namespace using image `httpd:alpine` and 2 replicas.
2.  Expose this deployment via a Service named `lb-service`.
3.  The Service MUST be of type `LoadBalancer`.
4.  Wait for the Service to receive an External IP address (provisioned by MetalLB).

## Validation

Verify that `lb-service` has type `LoadBalancer` and has been assigned an external IP.
