# Kustomize: HPA with Staging/Prod Overlays

A base Kustomize configuration for the `web-frontend` application exists at `/home/vagrant/kustomize-drill/base/`. It contains a Deployment, a Service, and a **legacy** ConfigMap called `scaling-config`.

Previously, the application used the ConfigMap to drive an external custom autoscaler. That approach is being replaced with a proper HorizontalPodAutoscaler.

Your tasks:

1. **Remove** the ConfigMap `scaling-config` completely from the base:
   - Delete the `scaling-config.yaml` resource reference from `base/kustomization.yaml`
   - Remove the `envFrom` ConfigMap reference from the Deployment spec in `base/deployment.yaml`

2. Create a **staging** overlay at `/home/vagrant/kustomize-drill/overlays/staging/`:
   - Add an HPA named `web-frontend` for the Deployment `web-frontend`
   - Min replicas: **2**, Max replicas: **4**
   - Scale at **50%** average CPU utilization
   - Set namespace to `web-staging`

3. Create a **prod** overlay at `/home/vagrant/kustomize-drill/overlays/prod/`:
   - Add an HPA named `web-frontend` for the Deployment `web-frontend`
   - Min replicas: **3**, Max replicas: **8**
   - Scale at **40%** average CPU utilization
   - Set namespace to `web-prod`

4. Apply both overlays:

   ```
   kubectl kustomize /home/vagrant/kustomize-drill/overlays/staging | kubectl apply -f -
   kubectl kustomize /home/vagrant/kustomize-drill/overlays/prod | kubectl apply -f -
   ```

## Information

- Each overlay needs its own `kustomization.yaml` referencing `../../base`
- Use `apiVersion: autoscaling/v2` for HPA
- Use `namespace:` in the overlay kustomization to set the target namespace
- The overlay `kustomization.yaml` should list both the base reference and any additional resources


## Validation

Verify the HPA and Deployments in both namespaces:
```bash
kubectl get hpa,deploy -n web-staging
kubectl get hpa,deploy -n web-prod
```
Ensure `kustomization.yaml` in base no longer references `scaling-config`:
```bash
grep scaling-config /home/vagrant/kustomize-drill/base/kustomization.yaml
# Should return nothing
```
