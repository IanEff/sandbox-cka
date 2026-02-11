---
tags: ["type/concept", "source/helm_notes", "status/seed"]
aliases: ["Helm Deep Dive"]
---

# Concept - Helm Deep Dive

# Notes - Learning Helm

Values:

In a values.yaml:

```yaml
drupalUsername: admin
mariadb:
  db:
    name: "my-database"
```

`helm install mysite bitnami/drupal --set values.yaml`

Imperatively:
`helm install mysite bitnami/drupal --set drupalUsername=admin --set mariadb.db.name=my-database`

Upgrading:

Really, this is just modifying any aspect of the installation, e.g. turning off ingress:

`helm upgrade mysite bitnami/drupal --set ingress.enabled=false`

**INSTALLS AND UPGRADES BOTH NEED VALUES**
$ helm install mysite bitnami/drupal --values values.yaml
$ helm upgrade mysite bitnami/drupal  <========= **SHITTY POOPY DEFAULT VALUES**

$ helm upgrade mysite bitnami/drupa --reuse-values
or
$ helm upgrade mysite bitnami/drupa --values values.yaml

Note: helm stores all its configs as *Secrets*

Dry runs and templating

Render just the yaml, please:
`helm template <installation> <repo>/<chartnane> --values values.yaml --set ...`

Render the whole shebang:
`helm install <installation> <repo>/<chartnane> --values values.yaml --set ... --dry-run=client`

### Helm get

#### Release records

- Stored as secrets

helm list
helm list --all

`helm get notes`

- renders notes

Helm-side:
`helm get values`

- Values supplied during the latest release

`helm get values --all`

- *THE COMMAND YOU'RE ALWAYS LOOKING FOR*
or
`helm inspect values <chartname>`:w

Cluster-side:
`helm get manifest`

- actual objects

Robot says:

1. Check the "Receipt": helm get values <release>

Is the setting I changed actually there?

1. Check the "Product": helm get manifest <release>

Did the chart turn my value into the correct YAML? (e.g., did port: 80 actually land in the Service manifest?)

1. Check the "Live Object": kubectl get pod <pod-name> -o yaml

Is Kubernetes actually running what Helm sent?

### History and rollbacks

helm history

---
**Topics:** [[Topic - Networking]], [[Topic - Security]], [[Topic - Tooling]], [[Topic - Workloads]]
