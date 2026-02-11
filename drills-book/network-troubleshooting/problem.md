# Network Troubleshooting Scenario

A developer reports that their application can't connect to a backend service, but the Pods are all running.

**Scenario Setup** (Created by `setup.sh`):

* Namespace `broken-app` exists
* Deployment `frontend` (3 replicas) trying to connect to service `backend-svc`
* Deployment `backend` (2 replicas) is running
* Service `backend-svc` was created but something's wrong

**Your Tasks**:

1. Investigate why the frontend can't reach the backend service.
2. Check the Service definition and write any issues you find to `/opt/course/overlay8/service-issues.txt`
3. Check if the Service has endpoints: `kubectl get endpoints -n broken-app backend-svc` and write the output to `/opt/course/overlay8/endpoints.txt`
4. Examine the backend Deployment's Pod labels and the Service selector - write any mismatches to `/opt/course/overlay8/label-mismatch.txt`
5. Fix the issue (either modify the Service selector or add labels to the Pods)
6. Verify the fix by exec'ing into a frontend Pod and curling `backend-svc:80` (or the appropriate service name/port).
    * Write the successful curl output to `/opt/course/overlay8/success.txt`
7. Document what was wrong and how you fixed it in `/opt/course/overlay8/postmortem.txt`

**Verification**: After your fix, `kubectl get endpoints -n broken-app backend-svc` should show the backend Pod IPs, and the frontend should successfully connect.
