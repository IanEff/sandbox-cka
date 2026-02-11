# Pod Network Tracing

Solve this question on: **Any node** (Control Plane or Worker).

The network team wants to understand how Pod-to-Pod communication works across nodes.

1. Create two Pods in Namespace `net-lab`:
    * Pod `sender` on one node (use `nodeName`) with image `nicolaka/netshoot` (or `busybox` if netshoot unavailable).
    * Pod `receiver` on a **different** node (use `nodeName`) with image `nginx:1-alpine`.
    * *Tip*: Run `kubectl get nodes` to see available node names (e.g., `ubukubu-worker-01`). If you only have one node, place both on the same node but understand traffic won't cross the physical network.
2. Capture the IP addresses of both Pods and write them to `/opt/course/overlay2/pod-ips.txt` in format `sender: <IP>` and `receiver: <IP>`
3. From the `sender` Pod, run a ping test to the `receiver` Pod (3 packets) and write the output to `/opt/course/overlay2/ping-result.txt`
4. On the node running the `sender` pod, examine the routing table and find the route that would handle traffic to the receiver Pod's IP.
    * Write that specific route line into `/opt/course/overlay2/route-to-receiver.txt` (Note: Write this file on the Control Plane node at the specified path).
5. Use `tcpdump` on the node to capture ICMP traffic while pinging from sender to receiver. Write the command you used into `/opt/course/overlay2/tcpdump-cmd.sh`

**Bonus**: If the cluster uses Calico, check for the veth pair connecting the sender Pod. If it uses an encapsulation-based CNI (like Cilium VXLAN), capture and examine a VXLAN packet.
