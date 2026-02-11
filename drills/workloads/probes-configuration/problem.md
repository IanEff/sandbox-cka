# Drill: Probe Problem

The pod `probe-fail` is... well, failing. It's stuck in a cycle of restarts or just isn't ready.

1. **Liveness Probe**: It's trying to `cat` a file that doesn't exist. Change it to check the file `/usr/share/nginx/html/index.html` matches existence, OR check TCP port 80.
2. **Readiness Probe**: It's checking port 81. Nginx runs on port 80. Fix it.
3. Ensure the pod is **Running** and **Ready**.

*Note: You may need to edit the running pod manifest (export, delete, edit, apply) or edit in place if kubectl allows (usually limited).*
