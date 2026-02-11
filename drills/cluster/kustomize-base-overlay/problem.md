# Drill: Kustomize Base & Overlay

## Question

**Context:**
A Kustomize project is set up in `~/kust-drill`.
The folder structure contains a `base` and an `overlays/prod` directory.

**Task:**
Modify the overlay at `~/kust-drill/overlays/prod` to meet these requirements:

1. Set the `replicaCount` of the Deployment to `2`.
2. Apply a common label `variant: production` to all resources in this overlay.
3. Ensure the resources are deployed into the Namespace `prod-ns`.

Finally, build and apply the `prod` overlay to the cluster. (Create the Namespace `prod-ns` if it does not exist).

## Hints

* `kubectl kustomize <directory>`
* `kubectl apply -k <directory>`
* `images`, `replicas`, `namespace`, `commonLabels` fields in `kustomization.yaml`.
