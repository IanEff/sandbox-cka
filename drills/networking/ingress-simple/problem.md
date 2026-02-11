# Simple Ingress Exposure

In namespace `web-exposed`, there is an existing service `web-svc` on port 80.

Create an Ingress resource named `web-ingress` that:

- Exposes `web-svc` on host `shop.example.com`.
- Path `/checkout` (prefix match).
- Uses port 80 of the service.
- **Ingress Class**: `nginx` (Assuming an Nginx controller is standard for this exam context, though usually not installed in this specific sandbox, we will just validate the resource spec).

(Note: For verification, we only check the correct creation of the Ingress object).
