# ServiceAccount API Access

## Objective

A Pod named `api-client` is running in namespace `security-drill` with ServiceAccount `api-reader`.
This ServiceAccount has permissions to `list` Pods in the namespace.

Your task is to:

1. Exec into the `api-client` pod.
2. Manually query the Kubernetes API server using `curl` and the ServiceAccount token mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token`.
3. Query the endpoint: `https://kubernetes.default.svc/api/v1/namespaces/security-drill/pods`.
4. Save the exact JSON output to file `/tmp/pods.json` inside the container.

## Requirements

- Pod: `api-client`
- Namespace: `security-drill`
- Output File: `/tmp/pods.json` (inside the pod)
- Content: JSON list of pods in `security-drill` obtained from API.
