# Soft Node Affinity

## Objective
Schedule a Pod that *prefers* to run on a specific node, but can run elsewhere if necessary.

## Instructions
1.  There are nodes in the cluster (e.g., `ubukubu-control`, `ubukubu-node-1`).
2.  Create a Pod named `preferred-pod` in the `default` namespace.
3.  The Pod should use the image `nginx:alpine`.
4.  Configure **Node Affinity** such that the Pod **prefers** to be scheduled on a node with the label `disk=ssd`.
    *   Set the weight of this preference to `50`.
5.  If no node has this label, the Pod should still successfully schedule on an available node.

## Verification
The Pod `preferred-pod` should be in the `Running` state, and its specification should contain the correct `preferredDuringSchedulingIgnoredDuringExecution` configuration.
