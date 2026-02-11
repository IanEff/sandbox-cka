# Service Headless Discovery

**Drill Goal:** Create a Headless Service for direct Pod discovery.

## Problem

1.  Create a Deployment named `backend-db` in `default` namespace (image `nginx:alpine`, replicas 2).
2.  Expose this Deployment via a Service named `db-headless`.
3.  The Service MUST be **Headless** (ClusterIP set to None).
4.  It should expose port 80.

## Validation

Verify that the Service has `ClusterIP: None` and correct selectors.
