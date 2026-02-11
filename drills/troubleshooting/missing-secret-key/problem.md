# Troubleshooting: Missing Secret Key

The pod controlled by deployment `app-viewer` in namespace `debug-me` is failing to start.

1. Diagnose the cause of the failure.
2. Fix the issue so that the application starts successfully.
3. The application requires the environment variable `API_KEY` to be populated from the secret `app-config`.
