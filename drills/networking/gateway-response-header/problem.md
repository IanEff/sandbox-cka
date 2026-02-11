# Gateway Response Header

## Objective

Update the existing HTTPRoute named `header-route` in the `gateway-test` namespace.
Configure it to add a response header `X-Verified: true` to all responses served by this route.

## Requirements

- Namespace: `gateway-test`
- HTTPRoute: `header-route`
- Action: Add Response Header
- Header Name: `X-Verified`
- Header Value: `true`
