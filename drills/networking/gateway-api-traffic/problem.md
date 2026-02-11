# Gateway API Traffic Splitting

The team from Project r500 wants to replace their Ingress with a Gateway API solution using the installed `convoy` GatewayClass.

## Requirements

Perform the following in Namespace `project-r500`:

1. Identify the existing Gateway named `project-gateway` (created by the setup script).
2. Create a new `HTTPRoute` named `traffic-director` attached to that Gateway.
3. Configure the rules to match the legacy Ingress logic AND new requirements:
    * Path `/desktop` should route to Service `desktop` (port 80).
    * Path `/mobile` should route to Service `mobile` (port 80).
    * Path `/auto` should define a complex rule:
        * If the header `User-Agent` **exact matches** `mobile` -> route/redirect to Service `mobile`.
        * Otherwise (default) -> route/redirect to Service `desktop`.

## Verification Criteria

The following commands should return valid 200 responses from the respective services:

```bash
# Assuming the Gateway IP is available
curl <GATEWAY_IP>/desktop
curl <GATEWAY_IP>/mobile
curl -H "User-Agent: mobile" <GATEWAY_IP>/auto  # Should go to mobile
curl -H "User-Agent: chromium" <GATEWAY_IP>/auto # Should go to desktop
```
