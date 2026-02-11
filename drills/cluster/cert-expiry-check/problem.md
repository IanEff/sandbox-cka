# Drill: Check Certificate Expiration

## Scenario

As a CKA administrator, you must be able to verify when the cluster control plane certificates expire.

## Task

1. Using `kubeadm`, checking the expiration date of the cluster certificates on the control plane node.
2. Write the expiration date of the `apiserver` certificate to `/opt/certificate_expiry.txt`.
   - Format: The output line from the kubeadm command is sufficient, e.g., `Aug 14 10:52:13 2026 GMT`.

## Context

You are already on the control plane node (or have access to it).


## Validation

Verify the file content matches the apiserver expiry date:
```bash
cat /opt/certificate_expiry.txt
kubeadm certs check-expiration | grep apiserver
```
