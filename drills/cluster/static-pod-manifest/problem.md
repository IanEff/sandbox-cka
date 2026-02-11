# Drill: Static Shock

Create a **Static Pod** named `static-web` on the **control plane node** (`ubukubu-control`).

- Image: `nginx`
- Namespace: `default` (implied by kubelet, but resulting mirror pod will be in default)

**Hint**: You need to SSH into `ubukubu-control` and find where the Kubelet looks for manifests.
