# PVC Resize

A deployment `data-app` in namespace `resize-test` is running low on storage. The attached PVC `data-pvc` needs to be expanded from 1Gi to 5Gi.

Expand the PVC without losing any data.

**Constraints:**
- The deployment must continue running.
- No data may be lost during the resize.
- The PVC name must remain `data-pvc`.
