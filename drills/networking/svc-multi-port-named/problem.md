# Drill: Multi-Port Named Service

## Problem

1. A Pod named `web-backend` is running in namespace `multi-port` (created for you).
2. It exposes two ports:
    * `80` named `http-backend`
    * `443` named `https-backend`
3. Create a Service named `web-service` in the same namespace.
4. The Service must expose:
    * Port `80` targeting the Pod's `http-backend` port (by name).
    * Port `443` targeting the Pod's `https-backend` port (by name).
5. The Service must allow connectivity to the Pod.
6. **Requirement:** You MUST use the port **names** in the Service `targetPort` field, not the numbers.

## Reference

* <https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service>
