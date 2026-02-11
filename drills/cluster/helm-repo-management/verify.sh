#!/bin/bash
# Verify for helm-repo-management

# Check Repo
helm repo list | grep bitnami >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Bitnami repo not found"
    # Don't fail hard if they named it something else but installed correctly? 
    # But usually instruction implies naming it bitnami or similar.
    # Proceed to check install
fi

# Check Install
kubectl get deploy -n web-ns -l app.kubernetes.io/instance=web-server >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Release web-server not found in web-ns"
    exit 1
fi

echo "Drill passed."
exit 0
