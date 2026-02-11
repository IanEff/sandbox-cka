# Operator Repair

## Instructions

A "dummy-operator" running in the `default` namespace is crashing.
It is supposed to watch ConfigMaps, but it seems to lack permissions.

Investigate the RBAC permissions associated with the `dummy-operator` ServiceAccount and fix the issue.

## Verification

The `dummy-operator` pod must be in a Running state and its logs should show "Watching ConfigMaps...".
