# Drill: Kustomize Overlays - Environment Configuration

## Objective

You are managing a Deployment called `web-app` using Kustomize. You have a `base` configuration, but you need to create a specific configuration for the `prod` environment.

## Instructions

1. Navigate to `/home/vagrant/kustomize-lab`.
2. Create a Kustomize overlay in `overlays/prod`.
3. The overlay must:
    * Inherit from `../../base`.
    * Set the `replicas` count of the deployment to **4**.
    * Add a common label `env: prod` to all resources.
    * Change the image tag to `nginx:1.25`.
4. Generate the manifest and apply it to the `k2-prod` namespace (create the namespace if it doesn't exist).

## Constraints

* Do NOT modify the `base` directory.
* The final Deployment in `k2-prod` must have 4 replicas and the correct image.
