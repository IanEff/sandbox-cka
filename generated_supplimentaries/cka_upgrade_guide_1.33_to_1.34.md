# CKA Upgrade Guide: Kubernetes v1.33 to v1.34

This guide outlines the standard procedure for upgrading a Kubernetes cluster using `kubeadm`, as expected in the CKA exam.

**Note:** Always upgrade the **Control Plane** node(s) first, then the **Worker** nodes.

## 1. Upgrade Control Plane Node

Perform these steps on the Control Plane node.

### A. Drain the Node

Evict workloads to ensure stability during the upgrade.

```bash
# Replace <cp-node-name> with your actual node name
kubectl drain <cp-node-name> --ignore-daemonsets
```

### B. Upgrade kubeadm

1. **Update the package repository** to point to v1.34.
    * Edit `/etc/apt/sources.list.d/kubernetes.list`.
    * Change `v1.33` to `v1.34`.
    * *Note: You may need to download the new key if the major version signing key changed, but usually for minor versions on pkgs.k8s.io, just the repo URL update is needed.*

    ```bash
    # Example of updating the repo list
    sudo sed -i 's/v1.33/v1.34/g' /etc/apt/sources.list.d/kubernetes.list
    ```

2. **Update package index and install new kubeadm**.

    ```bash
    sudo apt-get update
    sudo apt-get install -y --allow-change-held-packages kubeadm=1.34.0-1.1
    ```

    *(Check available versions with `apt-cache madison kubeadm` if needed)*.

3. **Verify version**.

    ```bash
    kubeadm version
    ```

### C. Plan and Apply Upgrade

1. **Verify the upgrade plan**.

    ```bash
    sudo kubeadm upgrade plan
    ```

    *Look for the output confirming you can upgrade to v1.34.x.*

2. **Apply the upgrade**.

    ```bash
    sudo kubeadm upgrade apply v1.34.0
    ```

    *Wait for the "SUCCESS" message.*

### D. Upgrade Kubelet and Kubectl

1. **Install the new versions**.

    ```bash
    sudo apt-get install -y --allow-change-held-packages kubelet=1.34.0-1.1 kubectl=1.34.0-1.1
    ```

2. **Restart Kubelet**.

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
    ```

### E. Uncordon the Node

Bring the node back into scheduling.

```bash
kubectl uncordon <cp-node-name>
```

---

## 2. Upgrade Worker Nodes

Perform these steps for **each** worker node.

### A. Drain the Worker Node

**Run this from the Control Plane node** (or wherever you have kubectl access).

```bash
kubectl drain <worker-node-name> --ignore-daemonsets
```

### B. Upgrade kubeadm (On the Worker Node)

SSH into the worker node.

1. **Update the package repository** (same as Control Plane).

    ```bash
    sudo sed -i 's/v1.33/v1.34/g' /etc/apt/sources.list.d/kubernetes.list
    ```

2. **Install new kubeadm**.

    ```bash
    sudo apt-get update
    sudo apt-get install -y --allow-change-held-packages kubeadm=1.34.0-1.1
    ```

### C. Upgrade Node Configuration

**On the Worker Node:**

```bash
sudo kubeadm upgrade node
```

### D. Upgrade Kubelet and Kubectl (On the Worker Node)

1. **Install new versions**.

    ```bash
    sudo apt-get install -y --allow-change-held-packages kubelet=1.34.0-1.1 kubectl=1.34.0-1.1
    ```

2. **Restart Kubelet**.

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
    ```

### E. Uncordon the Worker Node

**Run this from the Control Plane node.**

```bash
kubectl uncordon <worker-node-name>
```

---

## 3. Verification

Check that all nodes are reporting the new version.

```bash
kubectl get nodes
```

You should see `v1.34.x` in the VERSION column for all nodes.
