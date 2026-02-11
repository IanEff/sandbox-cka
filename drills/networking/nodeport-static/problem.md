# Static NodePort

In namespace `public-access`:

1. Create a Deployment `echo-server` using image `registry.k8s.io/e2e-test-images/agnhost:2.39`.
2. Configure the container to run the command: `["/agnhost", "netexec", "--http-port=8080"]`.
3. Expose this Deployment via a Service named `echo-nodeport`.
4. Type: `NodePort`.
4. The Service must listen on port `8080` and forward to container port `8080`.
5. **Constraint**: The `nodePort` must be exactly `30050`.

Verify you can reach it via `<NodeIP>:30050`.
