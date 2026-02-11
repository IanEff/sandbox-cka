#!/bin/bash
set -e

# Check ServiceAccount exists
if ! kubectl get serviceaccount monitor-sa -n monitoring &>/dev/null; then
    echo "❌ ServiceAccount 'monitor-sa' not found in monitoring namespace"
    exit 1
fi

# Check ClusterRole exists
if ! kubectl get clusterrole cluster-reader &>/dev/null; then
    echo "❌ ClusterRole 'cluster-reader' not found"
    exit 1
fi

# Check ClusterRoleBinding exists
if ! kubectl get clusterrolebinding monitor-binding &>/dev/null; then
    echo "❌ ClusterRoleBinding 'monitor-binding' not found"
    exit 1
fi

# Verify ClusterRole has correct permissions
# Check for pods
pods_verbs=$(kubectl get clusterrole cluster-reader -o jsonpath='{.rules[?(@.resources[0]=="pods")].verbs}' | tr -d '[]"' | tr ',' ' ')
if [[ ! "$pods_verbs" =~ "get" ]] || [[ ! "$pods_verbs" =~ "list" ]] || [[ ! "$pods_verbs" =~ "watch" ]]; then
    echo "❌ ClusterRole missing required verbs for pods (found: $pods_verbs)"
    exit 1
fi

# Check for nodes
nodes_verbs=$(kubectl get clusterrole cluster-reader -o jsonpath='{.rules[?(@.resources[0]=="nodes")].verbs}' | tr -d '[]"' | tr ',' ' ')
if [[ ! "$nodes_verbs" =~ "get" ]] || [[ ! "$nodes_verbs" =~ "list" ]]; then
    echo "❌ ClusterRole missing required verbs for nodes (found: $nodes_verbs)"
    exit 1
fi

# Verify binding references correct role and service account
role_ref=$(kubectl get clusterrolebinding monitor-binding -o jsonpath='{.roleRef.name}')
if [ "$role_ref" != "cluster-reader" ]; then
    echo "❌ ClusterRoleBinding references role '$role_ref', expected 'cluster-reader'"
    exit 1
fi

sa_name=$(kubectl get clusterrolebinding monitor-binding -o jsonpath='{.subjects[0].name}')
sa_namespace=$(kubectl get clusterrolebinding monitor-binding -o jsonpath='{.subjects[0].namespace}')
if [ "$sa_name" != "monitor-sa" ] || [ "$sa_namespace" != "monitoring" ]; then
    echo "❌ ClusterRoleBinding does not reference correct ServiceAccount"
    exit 1
fi

# Test permissions using auth can-i
if ! kubectl auth can-i list pods --as=system:serviceaccount:monitoring:monitor-sa --all-namespaces &>/dev/null; then
    echo "❌ ServiceAccount cannot list pods across namespaces"
    exit 1
fi

if ! kubectl auth can-i get nodes --as=system:serviceaccount:monitoring:monitor-sa &>/dev/null; then
    echo "❌ ServiceAccount cannot get nodes"
    exit 1
fi

# Verify NO write permissions
if kubectl auth can-i create pods --as=system:serviceaccount:monitoring:monitor-sa -n default &>/dev/null; then
    echo "❌ ServiceAccount has write permissions (should be read-only)"
    exit 1
fi

echo "✅ ClusterRole and ClusterRoleBinding configured correctly"
exit 0
