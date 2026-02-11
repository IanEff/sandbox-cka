# NetPol Ingress Namespace

**Drill Goal:** Allow Ingress traffic based on Namespace labels.

## Problem

1.  Create a namespace named `secure-app`.
2.  Create a NetworkPolicy named `allow-trusted-ns` in `secure-app`.
3.  The policy should apply to ALL pods in `secure-app`.
4.  It should allow **Ingress** traffic ONLY from any Pod running in a namespace labelled `project=trusted`.

## Validation

Verify the Ingress rule uses `namespaceSelector` with the correct label matching.
