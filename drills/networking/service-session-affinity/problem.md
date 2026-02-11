# Service Session Affinity

**Drill Goal:** Configure Service session affinity to stick clients to the same Pod.

## Problem

1.  Create a namespace named `sticky-session`.
2.  Create a Deployment named `backend` with image `nginx`, 3 replicas, and label `app=backend`.
3.  Create a Service named `backend-svc` exposing this Deployment on port 80.
4.  Configure the Service to use **ClientIP** based session affinity.
5.  Set the session affinity timeout to **10800 seconds** (3 hours).

## Validation

Verify that the Service is configured with `ClientIP` affinity and the correct timeout.
