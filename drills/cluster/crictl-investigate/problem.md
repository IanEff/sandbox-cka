# crictl Investigation

## Scenario

A pod named `mystery-pod` is running in the `default` namespace.
Administrative access to Kubernetes API is limited, but you have root access to the node.
You need to identify the **Container Runtime ID** of the container running inside this pod using `crictl`.

## Requirements

- **Pod**: `mystery-pod` (Namespace: `default`)
- **Node**: It is scheduled on the control plane (or you can ssh to the worker if applicable, but for this drill assuming control plane or `vagrant ssh` access). *Note*: The drill runner runs on the control plane so `crictl` is available locally.
- **Task**:
  1. Use `crictl` to find the container ID for the pod `mystery-pod`.
  2. Write the **full container ID** (sha256) to `/opt/mystery-id.txt`.

## Verification

The drill checks if the ID in the file matches the actual runtime ID.
