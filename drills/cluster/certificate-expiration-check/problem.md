# Certificate Expiration Check

As part of cluster maintenance, you need to check the expiration dates of the Kubernetes cluster certificates and understand which certificates are approaching expiration.

Requirements:

- Use `kubeadm` to check certificate expiration
- Identify certificates that expire within the next 90 days (if any)
- Create a file `/tmp/cert-status.txt` containing the output of the certificate check
- Understand which components would be affected by expired certificates

Current state: The cluster is running normally, but certificates need to be audited.

Note: This is a read-only inspection drill. You are NOT required to renew certificates, only to check their status.

Hints:

- kubeadm has a command for checking certificate expiration
- The command should be run on the control plane node
- Output should include certificate names and expiration dates
