#!/bin/bash
# troubleshooting/service-port-mismatch/verify.sh

# We verify by checking the spec primarily, or by attempting a curl.
# Let's check the spec first as it's faster.

TARGET_PORT=$(kubectl get svc port-test-svc -o jsonpath='{.spec.ports[0].targetPort}')

# Nginx listens on 80. If targetPort is 80 (int) or "http" (string), it's good.
if [ "$TARGET_PORT" == "80" ] || [ "$TARGET_PORT" == "http" ]; then
    echo "SUCCESS: targetPort is fixed ($TARGET_PORT)."
else
    # Connectivity check just in case they changed the pod port instead?
    # Unlikely but let's try a quick curl.
    kubectl run verify-curl --image=curlimages/curl --restart=Never --rm -i --timeout=5s -- curl -s --connect-timeout 2 http://port-test-svc
    if [ $? -eq 0 ]; then
        echo "SUCCESS: Connectivity works."
    else
        echo "FAIL: targetPort is $TARGET_PORT and connectivity fails."
        exit 1
    fi
fi
