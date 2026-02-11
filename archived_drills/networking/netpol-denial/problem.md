# Netpol Denial

The `secure-backend` namespace has a "Default Deny" Network Policy in place.
The `public-frontend` namespace has a `web` pod that needs to access the `db-service` (Redis) in `secure-backend`.

Currently, the connection times out.

**Tasks:**
1.  Create a NetworkPolicy in `secure-backend` named `allow-frontend`.
2.  Allow traffic from pods with label `app=web` in the namespace `public-frontend` to the pod with label `app=db` on port 6379.
