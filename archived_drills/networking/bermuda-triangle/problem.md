# The Bermuda Triangle

Flight `19` (pod `pilot`) is trying to contact the `control-tower`, but all signals are being lost in the void.
The `control-tower` is located in the `atlantic` namespace, and the `pilot` is in the `airspace` namespace.

**Your Task:**
Ensure that the `pilot` can successfully `curl` the `control-tower` on port 80.
Warning: There is a heavy magnetic anomaly (NetworkPolicy) protecting the `atlantic` namespace. You must navigate it.

**Verification:**
`curl` from `pilot` to `control-tower.atlantic` must succeed.
