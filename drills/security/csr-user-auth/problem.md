# Drill: CSR User Authentication

## Scenario

A new developer `jane` is joining the team. She needs access to the cluster.

You need to:

1. Create a private key `jane.key` (2048-bit RSA) and a Certificate Signing Request (CSR) `jane.csr` with Common Name (CN) `jane` and Organization (O) `devs` in `/home/vagrant/`.
2. Create a Kubernetes `CertificateSigningRequest` object named `jane` using the base64 encoded CSR.
3. Approve the CSR using `kubectl`.
4. Retrieve the signed certificate `jane.crt` from the API object.
5. Create a new context `jane-context` in your kubeconfig that uses:
    - The cluster `kubernetes` (or `default`)
    - The user `jane` (using the key and crt)
    - The namespace `default`

## Constraints

- Working directory: `/home/vagrant/`
- Context Name: `jane-context`
- User Name: `jane`
