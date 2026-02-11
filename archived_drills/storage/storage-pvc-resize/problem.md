# Storage PVC Resize

## Instructions

There involves a PersistentVolumeClaim named `data-claim` which is bound and has a capacity of `50Mi`.

Resize this PVC to `100Mi`.

## Verification

The PVC `data-claim` must have a capacity of `100Mi` and be in `bound` state.
