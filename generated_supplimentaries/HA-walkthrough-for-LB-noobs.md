# CKA High Availability (HA) Walkthrough for LB Noobs

This guide walks you through setting up a Stacked Etcd High Availability cluster using `kubeadm` and our external **HAProxy Load Balancer**.

**Goal:** Create a 3-node Control Plane cluster provided by:
- `ubukubu-control` (192.168.56.10)
- `ubukubu-control-2` (192.168.56.41)
- `ubukubu-control-3` (192.168.56.42)

**Load Balancer:**
- Hosted on your Mac (Host OS) via Docker.
- **Endpoint:** `192.168.56.1:6443`

---

## 1. Prerequisites

### Start the Infrastructure
Ensure your Host LB is running.
```bash
bash scripts/infra.sh up
```

### Provision Nodes
You need at least 3 control plane nodes. In our `Vagrantfile`:
- `ubukubu-control` is the primary (auto-provisioned).
- `ubukubu-control-2` and `ubukubu-control-3` are "prepared" nodes (software installed, but no cluster config).

```bash
# Bring up the squad
vagrant up ubukubu-control ubukubu-control-2 ubukubu-control-3
```

---

## 2. Bootstrap First Control Plane

Log into the **first** node.
```bash
vagrant ssh ubukubu-control
```

Run `kubeadm init`. **Crucial:** You must specify the `--control-plane-endpoint` pointing to our Host IP (`192.168.56.1`) and use `--upload-certs` to auto-share certificate secrets.

```bash
sudo kubeadm init \
  --control-plane-endpoint "192.168.56.1:6443" \
  --upload-certs \
  --pod-network-cidr=10.244.0.0/16
```

> **Why `192.168.56.1`?**
> This is the IP address of the VirtualBox Host-Only adapter on your Mac. Our HAProxy container is listening on this IP.

### Save the Output!
You will see two join commands.
1. **Control Plane Join:** Includes `--control-plane` and a `--certificate-key`.
2. **Worker Join:** Just the token and hash.

Example (Do not copy, use yours):
```bash
# CONTROL PLANE JOIN
kubeadm join 192.168.56.1:6443 --token <token> \
    --discovery-token-ca-cert-hash sha256:<hash> \
    --control-plane --certificate-key <key>

# WORKER JOIN
kubeadm join 192.168.56.1:6443 --token <token> ...
```

### Setup Kubeconfig (Node 1)
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Install CNI (Flannel)
```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

---

## 3. Join Secondary Control Planes

Open new terminals for the other nodes.

### Node 2 (`ubukubu-control-2`)
```bash
vagrant ssh ubukubu-control-2
```
Paste the **Control Plane Join** command from Step 2.
```bash
sudo kubeadm join 192.168.56.1:6443 --token ... --control-plane --certificate-key ...
```

### Node 3 (`ubukubu-control-3`)
```bash
vagrant ssh ubukubu-control-3
```
Paste the same **Control Plane Join** command.
```bash
sudo kubeadm join 192.168.56.1:6443 --token ... --control-plane --certificate-key ...
```

---

## 4. Verification

Back on `ubukubu-control` (or from your Host if you synced config):

```bash
kubectl get nodes
```

**Expected Output:**
```
NAME                STATUS   ROLES           AGE     VERSION
ubukubu-control     Ready    control-plane   5m      v1.34.0
ubukubu-control-2   Ready    control-plane   2m      v1.34.0
ubukubu-control-3   Ready    control-plane   1m      v1.34.0
```

### Test Failover (The Fun Part)
1. In a separate terminal, watch the HAProxy stats or logs:
   ```bash
   bash scripts/infra.sh logs
   ```
2. Or use the browser UI: [http://localhost:8404](http://localhost:8404)
3. Power off one node (simulating failure):
   ```bash
   vagrant halt ubukubu-control
   ```
4. Access the cluster using `kubectl` (via the remaining nodes). It should still work!
   ```bash
   kubectl get pods -A
   ```

---

## Troubleshooting

- **Certificate Key Expired?**
  If you waited too long (>2 hours) between init and join, regenerate the key/command on the first node:
  ```bash
  kubeadm init phase upload-certs --upload-certs
  ```
- **Connection Refused?**
  Ensure HAProxy is running: `bash scripts/infra.sh status`.
  Ensure `192.168.56.1` is reachable from the VM: `ping 192.168.56.1`.
