# Rolling Update Strategy

A deployment needs to be updated with a new container image, but the rollout keeps failing because too many pods go down at once during the update.

## Task

A Deployment named `web-app` exists in the `production` namespace. It's currently using image `nginx:1.19`.

1. Update the deployment to use image `nginx:1.21`
2. Configure the rolling update strategy so that:
   - No more than 1 pod is unavailable during the update
   - No more than 2 pods above the desired count are created during the update
3. Verify the rollout completes successfully

The deployment should maintain availability throughout the update process.
