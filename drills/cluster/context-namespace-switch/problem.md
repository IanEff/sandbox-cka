# Context Namespace Switch

**Drill Goal:** Create and switch to a new kubeconfig context.

## Problem

1.  Create a namespace named `science`.
2.  Define a new kubeconfig context named `research`.
3.  The context `research` should point to the currently active cluster and user `kubernetes-admin`, but default to the namespace `science`.
4.  **Switch** to the `research` context.

## Validation

Verify that the current context is `research` and the default namespace is `science`.
