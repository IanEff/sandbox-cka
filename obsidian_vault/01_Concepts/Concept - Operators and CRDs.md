---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Chapter 7 - Operators and CRDs", "Operators and CRDs"]
---

# Concept - Operators and CRDs

**Operator:** A plugin to the platform that deploys, scales, upgrades, and manages apps.

- Consists of one or more CRDs (Custom Resource Definitions), a controller, and usually RBAC rules.

### ArgoCD Installation Saga

#### 1. Installing the Operator

From ArgoCD's page on `operatorhub.io`:

```bash
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.38.0/install.sh | bash -s v0.38.0
kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
```

(Installs into `operators` namespace)

#### 2. Monitoring Installation

```bash
kubectl get csv -n operators
```

#### 3. Creating a Custom Resource

Create a custom resource (e.g., Application) with YAML and deploy with `kubectl apply -f`.
View with:

```bash
kubectl describe application nginx
```

#### 4. Controllers

**Controller:** Performs the reconciliation loop by observing the state of the CR object and making API calls to reach the desired state.

### Installing Operators (Best Practice)

- Always check `operatorhub.io`.
- If problematic, find the community/official version on GitHub.
  - e.g., [MongoDB Operator Installation](https://github.com/mongodb/mongodb-kubernetes-operator/blob/master/docs/install-upgrade.md#procedure-using-kubectl)

---
**Topics:** [[Topic - Security]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
