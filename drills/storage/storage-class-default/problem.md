# Default Storage Class

## Problem

Create a new StorageClass named `high-iops` with the provisioner `kubernetes.io/no-provisioner` (or `rancher.io/local-path` if you prefer, but `no-provisioner` is fine for metadata only).

Configure this new StorageClass to be the **default** StorageClass for the cluster.

Ensure that any previous default StorageClass is no longer marked as default (if applicable).
