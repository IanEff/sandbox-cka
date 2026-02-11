# Pod Manifest Extraction

Extract the manifest of the running pod `kube-apiserver-ubukubu-control` in the `kube-system` namespace.
Save the clean YAML (without `status`, `managedFields`, `selfLink`, `uid`, `resourceVersion`, `creationTimestamp`) to `/home/vagrant/apiserver-manifest.yaml`.
It should be deployable as a new pod (though names might conflict, the YAML should be valid).
