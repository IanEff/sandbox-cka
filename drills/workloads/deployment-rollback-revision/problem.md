# Deployment Rollback

**Drill Goal:** Update a Deployment and then roll it back to the previous revision.

## Problem

1.  A Deployment named `nginx-deploy` is running in namespace `rollout-test` with image `nginx:1.21`.
2.  Update the Deployment to use image `nginx:1.22`.
3.  Wait for the rollout to complete.
4.  Realize that `1.22` has a bug! **Rollback** the Deployment to the previous revision (which used `1.21`).

## Validation

Verify that the current image is `nginx:1.21` and that the Deployment has at least 2 revisions in its history (indicating an update took place).
