---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Helm and Kustomize", "Chapter 8 - Helm and Kustomize"]
---

# Concept - Helm and Kustomize

### Helm

Artifact Hub is the primary source for charts.

- **Updating all repos:**

  ```bash
  helm repo update
  ```

- **Adding a repo:**

  ```bash
  helm repo add <name> <url>
  ```

- **Installing a chart (e.g., Jenkins):**

  ```bash
  helm install my-jenkins jenkinsci/jenkins --version 5.8.114
  ```

- **Show default values:**

  ```bash
  helm show values jenkinsci/jenkins
  ```

- **Uninstalling:**

  ```bash
  helm uninstall my-jenkins
  ```

- **Overriding values during install:**

  ```bash
  helm install my-jenkins jenkinsci/jenkins --version 4.6.4 \
    --set controller.adminUser=boss \
    --set controller.adminPassword=password \
    -n jenkins --create-namespace
  ```

- **Upgrading:**

You can modify the objects the chart rolls out with upgrades.

  ```bash
  helm upgrade my-jenkins jenkinsci/jenkins --version 5.8.114
  ```

  ```bash
  helm upgrade broken-app <chart_path_or_repo/chart_name> \
    --namespace default \
    --set image.repository=nginx \
    --set image.tag=alpine
  ```

For anonymous tricky bullshit drill problems, sometimes the location of the chart isn't obvious.

1. Retrieve the chart name

```bash
~/p/k/sandbox-kcna ❯❯❯ helm list                                             sandbox-kcna ⎇ main ⌫3?3+-43
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART             APP VERSION
broken-app      default         1               2026-01-03 15:15:28.676840684 +0000 UTC deployed        mychart-0.1.0     1.16.0
```

1. Create an overrides file:

```yaml
image:
  repository: nginx
  tag: latest
```

1. Apply the overrides with the upgrade operation
`helm upgrade broken-app mychart-0.1.0 -n default -f fix-values.yaml`

- **Searching for charts:**

  ```bash
  helm search repo stack
  ```

### Kustomize

Simplifies manifest management via overlays and patches.

- **Rendering manifests (stdout):**

  ```bash
  kubectl kustomize ./path/to/kustomization/dir
  ```

- **Applying manifests:**

  ```bash
  kubectl apply -k ./path/to/kustomization/dir
  ```

Requires a `kustomization.yaml` file listing resources and patches.

---
**Topics:** [[Topic - Security]], [[Topic - Tooling]], [[Topic - Troubleshooting]]
