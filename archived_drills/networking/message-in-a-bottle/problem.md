# Message in a Bottle

A castaway (pod `castaway`) has thrown a bottle into the ocean (Service `sos-signal`) hoping for rescue.
However, the bottle never seems to find anyone who can help. The Service has no endpoints!

**Your Task:**
Fix the `sos-signal` Service so that it correctly routes traffic to the `castaway` pod.

**Verification:**
The `sos-signal` Service must have at least one valid Endpoint.
