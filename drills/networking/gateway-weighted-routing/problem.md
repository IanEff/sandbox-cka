# Gateway API Weighted Traffic Split

Your team wants to perform a canary deployment using Gateway API to gradually shift traffic between two versions of a service.

## Task

Two services exist in the `default` namespace:

- `app-v1` (current production version)
- `app-v2` (new canary version)

A Gateway named `main-gateway` exists and listens on port 80.

Create an HTTPRoute named `weighted-route` that:

- Attaches to the `main-gateway`
- Matches HTTP requests with path prefix `/app`
- Splits traffic with 80% going to `app-v1` (port 8080) and 20% going to `app-v2` (port 8080)

Verify the HTTPRoute is created correctly with the proper weight distribution.
