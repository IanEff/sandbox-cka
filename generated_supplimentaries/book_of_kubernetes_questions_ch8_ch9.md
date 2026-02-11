Overlay and Service Networking Drills
Based on Chapters 8-9 of "The Book of Kubernetes"
Question 1: CNI Plugin Investigation
Solve this question on: ssh overlay-node1
You've inherited a cluster and need to document its networking configuration for the team.

Identify which CNI plugin is currently active on the cluster by examining /etc/cni/net.d/
Write the plugin name and CNI version into /opt/course/overlay1/cni-info.txt
List all available CNI plugin binaries in /opt/cni/bin/ and count them
Write the total count into /opt/course/overlay1/plugin-count.txt
Create a Pod named net-inspector using image busybox:1 that runs sleep 3600
Once running, capture its network namespace path and write it to /opt/course/overlay1/netns-path.txt

Verification: Your files should contain accurate information matching the cluster's actual CNI configuration. The network namespace path should follow the pattern /var/run/netns/cni-...

Question 2: Pod Network Tracing
Solve this question on: ssh overlay-node1
The network team wants to understand how Pod-to-Pod communication works across nodes.

Create two Pods in Namespace net-lab:

Pod sender on node overlay-node1 (use nodeName) with image nicolaka/netshoot
Pod receiver on node overlay-node2 (use nodeName) with image nginx:1-alpine

Capture the IP addresses of both Pods and write them to /opt/course/overlay2/pod-ips.txt in format sender: <IP> and receiver: <IP>
From the sender Pod, run a ping test to the receiver Pod (3 packets) and write the output to /opt/course/overlay2/ping-result.txt
On overlay-node1, examine the routing table and find the route that would handle traffic to the receiver Pod's IP
Write that specific route line into /opt/course/overlay2/route-to-receiver.txt
Use tcpdump on overlay-node1 to capture ICMP traffic while pinging from sender to receiver. Write the command you used into /opt/course/overlay2/tcpdump-cmd.sh

Bonus: If the cluster uses Calico, check for the veth pair connecting the sender Pod. If it uses an encapsulation-based CNI, capture and examine a VXLAN packet.

Question 3: Service Discovery Deep Dive
Solve this question on: ssh overlay-node1
Your application team is confused about how DNS works in the cluster.

Create a Deployment named web-backend in Namespace app-layer with 3 replicas using image nginx:1-alpine
Expose it with a ClusterIP Service named web-backend-svc on port 8080 → 80
Create a debug Pod named dns-detective in Namespace app-layer using image alpine running sleep 3600
From the debug Pod:

Look up web-backend-svc and write all returned IP addresses to /opt/course/overlay3/service-ips.txt
Examine /etc/resolv.conf and write the nameserver IP to /opt/course/overlay3/nameserver.txt
Write the search domains to /opt/course/overlay3/search-domains.txt

Create a second debug Pod named dns-detective-2 in Namespace default
From this Pod, perform a DNS lookup for web-backend-svc.app-layer.svc.cluster.local and write the result to /opt/course/overlay3/cross-ns-lookup.txt
Write a bash script at /opt/course/overlay3/test-dns.sh that tests if the service is reachable from both namespaces

Verification: The Service should resolve correctly from both namespaces, but using different query patterns based on the Pod's namespace.

Question 4: iptables Traffic Flow
Solve this question on: ssh overlay-node1
The security team needs to understand how kube-proxy implements Service routing.

Create a Deployment named payment-api with 2 replicas using image httpd:2-alpine in Namespace finance
Expose it with a ClusterIP Service named payment-svc on port 80
Capture the Service's ClusterIP and write it to /opt/course/overlay4/service-ip.txt
On overlay-node1, run iptables-save and grep for rules related to finance/payment-svc
Write the KUBE-SERVICES chain rules for this service into /opt/course/overlay4/service-rules.txt
Find the individual endpoint (KUBE-SEP) chains and write them to /opt/course/overlay4/endpoint-chains.txt
Explain in /opt/course/overlay4/explanation.txt (in your own words, 2-3 sentences) why ICMP ping doesn't work to the Service IP but HTTP does

Verification: Your iptables rules should show probability-based load balancing across the 2 Pod endpoints.

Question 5: NodePort Exposure
Solve this question on: ssh overlay-node1
You need to expose an application externally using NodePort.

Create a Deployment named api-gateway with 3 replicas using image nginx:1-alpine in Namespace external-apps
Create a Service named api-gateway-svc of type ClusterIP on port 80
Verify the Service works internally by creating a test Pod and curling the Service
Now convert the Service to NodePort type using kubectl patch
Write the NodePort assigned to /opt/course/overlay5/nodeport.txt
On overlay-node1, verify that kube-proxy is listening on that port using ss -nlp and write the output line to /opt/course/overlay5/listening-port.txt
Test connectivity by curling localhost:<NODEPORT> from the node itself
Write a curl command that would work from outside the cluster into /opt/course/overlay5/external-curl.sh (assume node IP is 192.168.1.100)

Verification: The Service should be accessible on the NodePort from any node in the cluster.

Question 6: Ingress Configuration Challenge
Solve this question on: ssh overlay-node1
The platform team wants you to set up Ingress routing for multiple applications.

Create three Deployments in Namespace web-apps:

blog with 2 replicas, image nginx:1-alpine, label app=blog
shop with 2 replicas, image nginx:1-alpine, label app=shop
docs with 1 replica, image nginx:1-alpine, label app=docs

Create three ClusterIP Services exposing each Deployment on port 80
Create an Ingress resource named web-router that:

Routes blog.example.com/ → blog service
Routes shop.example.com/ → shop service
Routes example.com/docs → docs service (path-based routing)

Write the Ingress YAML to /opt/course/overlay6/ingress.yaml
Test each route using curl with the -H "Host: <hostname>" flag against the Ingress controller's IP
Write all three working curl commands to /opt/course/overlay6/test-commands.sh
Check the Ingress controller's logs and write any configuration reload messages to /opt/course/overlay6/ingress-logs.txt

Verification: All three routes should return nginx welcome pages. The Ingress should show all three services as backends.

Question 7: Multi-Network Pod Configuration
Solve this question on: ssh overlay-node1
Your cluster uses Multus for multi-network support. A database team needs Pods with isolated storage network interfaces.

Examine the existing NetworkAttachmentDefinition resources and write their names to /opt/course/overlay7/network-attachments.txt
Create a NetworkAttachmentDefinition named storage-net in Namespace database with:

Type: macvlan
Mode: bridge
Subnet: 10.200.0.0/24
Range: 10.200.0.100 to 10.200.0.200

Create two Pods in Namespace database on the SAME node:

db-primary with image postgres:13-alpine, annotation to use storage-net
db-replica with image postgres:13-alpine, annotation to use storage-net

Verify both Pods have the additional net1 interface by exec'ing into each and running ip addr
Write the net1 IP addresses to /opt/course/overlay7/storage-ips.txt
From db-primary, ping db-replica's net1 IP and write the result to /opt/course/overlay7/storage-network-test.txt
Write an explanation in /opt/course/overlay7/use-case.txt: Why would you use a separate storage network? (2-3 sentences)

Verification: Both Pods should have two network interfaces and be able to communicate over the net1 interfaces on the storage network.

Question 8: Network Troubleshooting Scenario
Solve this question on: ssh overlay-node1
A developer reports that their application can't connect to a backend service, but the Pods are all running.
Scenario Setup:

Namespace broken-app exists
Deployment frontend (3 replicas) trying to connect to service backend-svc
Deployment backend (2 replicas) is running
Service backend-svc was created but something's wrong

Your Tasks:

Investigate why the frontend can't reach the backend service
Check the Service definition and write any issues you find to /opt/course/overlay8/service-issues.txt
Check if the Service has endpoints: kubectl get endpoints -n broken-app backend-svc and write the output to /opt/course/overlay8/endpoints.txt
Examine the backend Deployment's Pod labels and the Service selector - write any mismatches to /opt/course/overlay8/label-mismatch.txt
Fix the issue (either modify the Service selector or add labels to the Pods)
Verify the fix by exec'ing into a frontend Pod and curling backend-svc:80
Write the successful curl output to /opt/course/overlay8/success.txt
Document what was wrong and how you fixed it in /opt/course/overlay8/postmortem.txt

Verification: After your fix, kubectl get endpoints -n broken-app backend-svc should show the backend Pod IPs, and the frontend should successfully connect.

Bonus Challenge: The Complete Network Stack
Solve this question on: ssh overlay-node1
Demonstrate your understanding of the entire network stack by tracing a request from external client → Ingress → Service → Pod.

Create the full stack in Namespace full-stack:

Deployment api-server (2 replicas, nginx)
ClusterIP Service api-svc (port 8080 → 80)
Ingress api-ingress (routes api.test.com → api-svc)

Document the complete traffic flow in /opt/course/overlay8/traffic-flow.txt:

What happens when external request hits the Ingress controller NodePort?
How does Ingress controller determine which backend Service?
How does the Service route to a specific Pod?
What network interfaces does the packet traverse?

Capture this flow practically:

Run tcpdump on the node
Make a curl request through the Ingress
Write the captured packets showing the transformation to /opt/course/overlay8/packet-capture.txt

Bonus: Diagram the network path in ASCII art in /opt/course/overlay8/network-diagram.txt

This one's for the road warriors who really want to understand Kubernetes networking end-to-end!
