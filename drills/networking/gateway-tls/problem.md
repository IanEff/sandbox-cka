# Drill: Gateway TLS

## Scenario

Security is paramount. You need to configure a Gateway Listener to serve traffic securely over HTTPS.

## Task

1. Work in Namespace `gateway-tls`.
2. A TLS Secret named `secure-cert` has been created for you in the namespace (simulated, valid for `secure.test`).
3. Create a Gateway named `secure-gw`:
   - GatewayClass: `cilium`
   - Listener Name: `https-1`
   - Port: `443`
   - Protocol: `HTTPS`
   - Hostname: `secure.test`
   - TLS Certificate Ref: `secure-cert`

## Constraint

- Do not create any Routes (HTTPRoute), just the Gateway.
- Ensure the Gateway is Accepted/Programmed (it might stay 'Pending' if no Routes are attached depending on implementation, but the Spec must be correct).

## Hints

- `spec.listeners[].tls.certificateRefs`
- `gatewayClassName: cilium`
