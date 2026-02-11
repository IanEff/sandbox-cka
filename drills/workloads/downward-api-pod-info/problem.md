# Downward API Pod Info

Create a Pod named `downward-pod` using image `nginx:alpine`.
The Pod must expose the following information as Environment Variables using the Downward API:

- `POD_NAME`: The name of the Pod
- `POD_NAMESPACE`: The namespace of the Pod

The Pod should be in the `default` namespace.
