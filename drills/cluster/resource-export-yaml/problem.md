# Export Resources to YAML

## Problem

Export all `Service` resources that are currently in the `kube-system` namespace.
Save them to a single file `/opt/course/5/services.yaml`.

The format must be YAML.
It does NOT matter if you clean up the metadata (like managedFields, uids, creationTimestamp) or not, as long as the file contains valid manifests for all the services.
