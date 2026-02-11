# Ingress Configuration Challenge

The platform team wants you to set up Ingress routing for multiple applications.

1. Create three Deployments in Namespace `web-apps`:
    * `blog` with 2 replicas, image `nginx:1-alpine`, label `app=blog`
    * `shop` with 2 replicas, image `nginx:1-alpine`, label `app=shop`
    * `docs` with 1 replica, image `nginx:1-alpine`, label `app=docs`
2. Create three ClusterIP Services exposing each Deployment on port 80
3. Create an Ingress resource named `web-router` that:
    * Routes `blog.example.com/` → `blog` service
    * Routes `shop.example.com/` → `shop` service
    * Routes `example.com/docs` → `docs` service (path-based routing)
4. Write the Ingress YAML to `/opt/course/overlay6/ingress.yaml`
5. Test each route using `curl` with the `-H "Host: <hostname>"` flag against the Ingress controller's IP (if known/available) or Service.
    * Write all three working curl commands to `/opt/course/overlay6/test-commands.sh`
6. Check the Ingress controller's logs (if you have access to the namespace where Ingress Controller runs, often `ingress-nginx` or `kube-system`) and write any configuration reload messages to `/opt/course/overlay6/ingress-logs.txt`. (Skip if you lack access).

**Verification**: All three routes should return nginx welcome pages. The Ingress should show all three services as backends.
