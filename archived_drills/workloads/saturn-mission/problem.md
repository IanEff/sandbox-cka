# Drill: Saturn Mission

The mission to Saturn is stuck on the launchpad.

The pod `cassini` in namespace `mission-control` is currently `Pending`.
It needs to be scheduled on the node `ubukubu-node-1` (or any available worker node), but there seems to be a repel field preventing it.

**Your Task:**
Identify why `cassini` is not scheduling and fix it so that it runs successfully.
Do not remove the restriction from the node; the pod must adapt to the conditions.
