# Drill: Kubeconfig Extract

## Question

**Context:**
You have access to a standard `kubeconfig` file at `~/.kube/config`.
An external system requires the client certificate for the user `kubernetes-admin` (or the generic admin user defined in your context).

**Task:**

1. Extract the **client certificate data** for the admin user from the current `kubeconfig`.
2. Decode the Base64 data.
3. Save the resulting PEM-formatted certificate to the file `~/admin.crt`.

## Hints

* `kubectl config view --raw`
* `grep`, `jsonpath`, or `yq`
* `base64 -d`
