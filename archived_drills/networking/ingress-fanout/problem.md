# Ingress Fanout

## Instructions

Create an Ingress resource named `fanout` in the `default` namespace.

It should route traffic as follows:
*   Path `/video` (Prefix) -> Service `video-service` on port 80
*   Path `/stream` (Prefix) -> Service `stream-service` on port 80

The backend services `video-service` and `stream-service` already exist.

## Verification

The Ingress `fanout` must exist and be configured with the correct rules.
