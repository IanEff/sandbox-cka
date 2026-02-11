# Kustomize Overlay

## Instructions

There involves a Kustomize configuration located at **/opt/kustomize**.
It contains a `base` and an `overlay/prod`.

Apply the configuration from the `overlay/prod` directory.

## Verification

The resources defined in the overlay must be present in the cluster.
Specifically looking for resources named or labeled indicating they are from the `prod` overlay.
