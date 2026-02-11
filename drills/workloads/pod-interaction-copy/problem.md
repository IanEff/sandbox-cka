# Pod Interaction Copy

**Drill Goal:** Transfer files between the local host and a running Pod.

## Problem

1.  A Pod named `data-collector` is running in the `default` namespace (image `nginx:alpine`).
2.  Create a local file named `config.txt` containing the text `parameters=valid`.
3.  Copy this local file **into** the `data-collector` Pod at the path `/tmp/config.txt`.

## Validation

Verify that `/tmp/config.txt` exists inside the `data-collector` Pod and contains `parameters=valid`.
