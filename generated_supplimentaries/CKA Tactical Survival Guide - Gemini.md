# CKA Tactical Survival Guide

## I. The "First 30 Seconds" Setup

*Do this immediately upon starting your terminal session. It saves thousands of keystrokes.*

1. **The "Do" Variable:**
    Instead of typing the dry-run flag every time, export it as a variable.

    ```bash
    export do="--dry-run=client -o yaml"
    # Usage: k run nginx --image=nginx $do
    ```

2. **The Namespace Switcher:**
    You will constantly need to switch namespaces.

    ```bash
    alias kn='kubectl config set-context --current --namespace '
    # Usage: kn mercury (Now you are in namespace 'mercury')
    ```

3. **The Vim Setup:**
    Make YAML readable.

    ```bash
    echo 'set expandtab tabstop=2 shiftwidth=2 syntax on' >> ~/.vimrc
    er... mebbe..
    echo 'syntax on' >> ~/.vimrc
    ```

  1 set expandtab
  2 set tabstop=2
  3 set shiftwidth=2
  4 set autoindent
  5 set smartindent
  6 set bg=dark
  7 syntax on
  8 set number

1. **TEST THIS OUT** **The bash oshit setup**

    This *may* lick the terminal wrap thing for long commands:

    ```bash
    bind 'set horizontal-scroll-mode off'
    ```

---

## II. The "Creation" Loop (New Objects)

*Used for: "Create a deployment/pod/service..."*

**The Strategy:** Never write YAML from scratch.

1. **Generate:** `k create deploy my-dep --image=nginx --replicas=3 $do > deploy.yaml`
2. **Verify:** `cat deploy.yaml` (Quick eyeball check)
3. **Apply:** `k apply -f deploy.yaml`
4. **Validate:** `k get deploy` (Did it actually work?)

**Shortcuts:**

* **Pod:** `k run`
* **Deployment:** `k create deploy`
* **Service:** `k expose` (Fastest way to create a service for an existing pod/deploy)
  * *Example:* `k expose deploy my-dep --port=80 --target-port=8080 --name=my-svc $do`
* **CronJob:** `k create cronjob`

---

## III. The "Fixing" Loop (Troubleshooting)

*Used for: "This service isn't working..." or "Node is NotReady"*

### Scenario A: The App is Broken (The "Outside-In" Flow)

Don't guess. Follow the path of the traffic.

1. **Check Service:** `k get svc` -> Is the ClusterIP/Port correct?
2. **Check Endpoints:** `k get ep <service-name>`
    * **If EMPTY:** The Service selector does not match the Pod labels. **STOP.** Fix the Service selector.
    * **If POPULATED:** Traffic is getting to the pod. The issue is the Pod itself.
3. **Check Pod Status:** `k get pod`
    * `ImagePullBackOff` -> **Strategy:** `edit`. It's usually a typo in the image name.
    * `CrashLoopBackOff` -> **Strategy:** `logs`. The app is starting but dying (config error, missing secret).
    * `Pending` -> **Strategy:** `describe`. It's waiting for resources, scheduling (taints/tolerations), or a PVC.

### Scenario B: The Node is Broken (The "System" Flow)

When `kubectl` can't help you because the API server is down or the node is disconnected.

1. **SSH In:** `ssh <node-name>`
2. **Check Kubelet:** The Kubelet is the captain of the node.
    * `systemctl status kubelet` -> Is it running?
    * `journalctl -u kubelet | tail -n 20` -> Why is it unhappy? (Look for certificate errors or config path errors).
3. **Check Containers (Runtime):**
    * `crictl ps` -> Are the control plane static pods (etcd, api-server) actually running?
    * `crictl logs <container-id>` -> If the API server container is crashing, `kubectl` won't work, but this will.

---

## IV. The "Editing" Decision Tree

*When to use what command:*

| Scenario | Tool | Why? |
| :--- | :--- | :--- |
| **Fixing a typo / changing an image** | `kubectl edit` | Fast. Opens live object. Saves instantly. |
| **Changing a field that can't be edited (e.g., removing a container)** | `export do` + `replace` | `k get pod x $do > p.yaml` -> `k delete pod x` -> Edit file -> `k apply -f p.yaml` |
| **Adding a complex Taint/Label** | `kubectl taint/label` | Don't edit YAML for this. Use the imperative commands. |
| **Scaling** | `kubectl scale` | Fastest way to change replicas. |

---

## V. The "Gotchas" Checklist (Save your points)

*Before hitting "Next Question", glance at this:*

1. **Context Check:** Did I run this on the right cluster? (`k config use-context ...`)
2. **Namespace Check:** Did I create the resource in `default` when it asked for `saturn`?
3. **SSH Check:** Am I still logged into a worker node? (Type `exit` or you will fail the next questions).
4. **Privilege Check:** If a command says "Permission Denied" on a node, `sudo -i`.

## VI. Documentation Search Keys

*Don't browse. Search specific terms.*

* **PVCs:** Search "PersistentVolumeClaim" -> Copy the YAML block.
* **Ingress:** Search "Ingress" -> Copy the basic rule block.
* **NetworkPolicy:** Search "NetworkPolicy" -> Copy the "Deny All" or "Allow" block.
* **ETCD Backup:** Search "etcd snapshot" -> The exact command is in the docs.
