# Service NodePort Static

Expose the existing Deployment `nginx-deploy` (which listens on port 80) via a NodePort Service named `static-port`.
The Service must use the static NodePort `30080`.
The Service should be in the `default` namespace.
