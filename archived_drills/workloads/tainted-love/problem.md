# Tainted Love

The `precious-app` deployment is supposed to run on a dedicated "restricted" node.
The node has been prepared with the label `type=restricted` and a taint to keep other pods away.

However, the `precious-app` pods are stuck in `Pending`.

**Tasks:**
1.  Identify why the pods are not scheduling.
2.  Modify the `precious-app` deployment to satisfy the scheduling requirements.
3.  Ensure the pods are `Running` on the restricted node.
