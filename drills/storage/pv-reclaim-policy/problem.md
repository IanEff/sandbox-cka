# Persistent Volume Reclaim Policy

The storage team has a Persistent Volume that is currently set to be deleted when its claim is released. They need to change this policy to retain the data instead.

## Task

A PersistentVolume named `important-data-pv` exists in the cluster with a `Delete` reclaim policy. Change the reclaim policy to `Retain` so that when the PVC is deleted, the volume and its data are preserved.

Verify that the policy has been successfully updated.
