# Service Discovery Deep Dive

Your application team is confused about how DNS works in the cluster.

1. Create a Deployment named `web-backend` in Namespace `app-layer` with 3 replicas using image `nginx:1-alpine`
2. Expose it with a ClusterIP Service named `web-backend-svc` on port 8080 → 80
3. Create a debug Pod named `dns-detective` in Namespace `app-layer` using image `alpine` running `sleep 3600`
4. From the debug Pod:
    * Look up `web-backend-svc` and write all returned IP addresses to `/opt/course/overlay3/service-ips.txt` (Tip: use `nslookup` or `dig`)
    * Examine `/etc/resolv.conf` and write the nameserver IP to `/opt/course/overlay3/nameserver.txt`
    * Write the search domains to `/opt/course/overlay3/search-domains.txt`
5. Create a second debug Pod named `dns-detective-2` in Namespace `default`
    * From this Pod, perform a DNS lookup for `web-backend-svc.app-layer.svc.cluster.local` and write the result to `/opt/course/overlay3/cross-ns-lookup.txt`
6. Write a bash script at `/opt/course/overlay3/test-dns.sh` that tests if the service is reachable from both namespaces.

**Verification**: The Service should resolve correctly from both namespaces, but using different query patterns based on the Pod's namespace.
