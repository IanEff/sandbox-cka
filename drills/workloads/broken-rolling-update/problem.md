# Workloads: Broken Rolling Update

The deployment `web-app` in namespace `workloads-drill` was updated to a new version, but the pods are failing to pull the image.

1. Investigate the deployment status and the rollout history.
2. Roll back the deployment to the previous stable revision.
3. Ensure the deployment stabilizes and all replicas are up and running.
