# CRD Creation

## Instructions

Create a CustomResourceDefinition (CRD) with the following specifications:

*   **Group**: `stable.example.com`
*   **Version**: `v1`
*   **Kind**: `Backup`
*   **Plural**: `backups`
*   **Scope**: `Namespaced`

The content of the CRD schema is not important for this task, but the CRD itself must be created and registered with the API server.

## Verification

The CRD `backups.stable.example.com` must exist.
