# Drill: Kustomize Me Captain

Files are located in `~/kustomize-drill`.

1. Create a **production overlay** in `overlays/prod`.
2. The overlay must:
   - Use the resources from `../../base`.
   - Set the `replicas` count to **3**.
   - Add a label `env=prod` to the Deployment **and** the Pod Template.
3. Deploy the application to the `default` namespace using `kubectl apply -k ...`.

**Constraint**: Do NOT modify the files in `base/`.
