# Bonus Challenge: The Complete Network Stack

Demonstrate your understanding of the entire network stack by tracing a request from external client → Ingress → Service → Pod.

1. Create the full stack in Namespace `full-stack`:
    * Deployment `api-server` (2 replicas, `nginx`)
    * ClusterIP Service `api-svc` (port 8080 → 80)
    * Ingress `api-ingress` (routes `api.test.com` → `api-svc`)
2. Document the complete traffic flow in `/opt/course/overlay8/traffic-flow.txt`:
    * What happens when external request hits the Ingress controller NodePort?
    * How does Ingress controller determine which backend Service?
    * How does the Service route to a specific Pod?
    * What network interfaces does the packet traverse?
3. Capture this flow practically:
    * Run `tcpdump` on the node
    * Make a curl request through the Ingress (e.g., `curl -H "Host: api.test.com" http://<INGRESS_IP>`)
    * Write the captured packets showing the transformation to `/opt/course/overlay8/packet-capture.txt`
4. **Bonus**: Diagram the network path in ASCII art in `/opt/course/overlay8/network-diagram.txt`

**Verification**: Resources created, and files populated with detailed analysis.
