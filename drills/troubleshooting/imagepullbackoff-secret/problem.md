# ImagePullBackOff Resolution

A deployment in the `apps` namespace is failing with ImagePullBackOff errors. The deployment is trying to pull an image from a private container registry but lacks the necessary credentials.

Requirements:

- Create an appropriate secret with registry credentials
- Configure the deployment `private-app` to use the registry secret
- The deployment must successfully pull the image and pods must reach Running state

Current state:

- Deployment `private-app` exists but pods are in ImagePullBackOff
- The image is from a private registry (simulated scenario)
- You'll need to add imagePullSecrets configuration

Note: For this drill, fixing the image to use a public image OR properly configuring imagePullSecrets (even with dummy credentials that reference a public fallback) will satisfy the requirements.
