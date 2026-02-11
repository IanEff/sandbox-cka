# RBAC User CSR

**Task:**

1. Create a CertificateSigningRequest (CSR) for a user named `jane`.
   - The CSR should use the key `jane.key` (you may need to generate it).
   - The Common Name (CN) must be `jane`.
2. Approve the CSR using the Kubernetes API.
3. Retrieve the certificate and save it to `jane.crt`.
4. Create a Role named `pod-reader` in the `development` namespace that allows `list` and `get` on `pods`.
5. Bind this Role to the user `jane` using a RoleBinding named `jane-pod-reader`.
6. Configure kubectl to use context `jane-context` with the new credentials and verify access.

**Prerequisites:**

- Namespace `development` exists (created by setup).
