# CNI Plugin Investigation

Solve this question on: **The Control Plane Node** (where you are currently logged in).

You've inherited a cluster and need to document its networking configuration for the team.

1. Identify which CNI plugin is currently active on the cluster by examining `/etc/cni/net.d/`
    * Write the plugin name and CNI version into `/opt/course/overlay1/cni-info.txt`
2. List all available CNI plugin binaries in `/opt/cni/bin/` and count them
    * Write the total count into `/opt/course/overlay1/plugin-count.txt`
3. Create a Pod named `net-inspector` using image `busybox:1` that runs `sleep 3600`
4. Once running, capture its network namespace path and write it to `/opt/course/overlay1/netns-path.txt` (Hint: Check `/var/run/netns/...` or CNI logs/status if accessible, or `crictl`/`docker` inspect if available, or just verify the pattern).

**Verification**: Your files should contain accurate information matching the cluster's actual CNI configuration. The network namespace path should follow the pattern `/var/run/netns/cni-...` or related.
