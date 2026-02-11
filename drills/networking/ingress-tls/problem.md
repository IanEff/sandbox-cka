# Ingress TLS Configuration

An Ingress resource exists to route traffic to a web application, but it needs to be secured with TLS/HTTPS.

Requirements:

- Create a TLS secret named `webapp-tls-cert` in the `web` namespace
- The secret must contain a certificate and key (self-signed is acceptable)
- Update the existing Ingress `webapp-ingress` to use TLS
- Configure TLS for host `webapp.example.com`
- The Ingress must redirect HTTP to HTTPS or handle HTTPS traffic

Current state: An Ingress exists but serves only HTTP traffic. It needs TLS configuration.

Note: The cluster uses Cilium which includes Ingress controller capabilities.
