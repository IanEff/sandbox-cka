#!/bin/bash
# Verify Kustomize HPA Overlay Drill
set -e

ERRORS=0

# 1. Check ConfigMap removal from base kustomization
if grep -q "scaling-config" /home/vagrant/kustomize-drill/base/kustomization.yaml 2>/dev/null; then
    echo "FAIL: scaling-config.yaml still referenced in base kustomization.yaml"
    ERRORS=$((ERRORS + 1))
else
    echo "PASS: Legacy ConfigMap removed from base kustomization"
fi

# Check deployment no longer references the ConfigMap envFrom
if grep -q "scaling-config" /home/vagrant/kustomize-drill/base/deployment.yaml 2>/dev/null; then
    echo "FAIL: scaling-config still referenced in base deployment.yaml (envFrom)"
    ERRORS=$((ERRORS + 1))
else
    echo "PASS: ConfigMap envFrom reference removed from Deployment"
fi

# 2. Check staging overlay
echo ""
echo "--- Staging ---"
if ! kubectl get hpa web-frontend -n web-staging >/dev/null 2>&1; then
    echo "FAIL: HPA 'web-frontend' not found in namespace web-staging"
    ERRORS=$((ERRORS + 1))
else
    STAGING_MIN=$(kubectl get hpa web-frontend -n web-staging -o jsonpath='{.spec.minReplicas}')
    STAGING_MAX=$(kubectl get hpa web-frontend -n web-staging -o jsonpath='{.spec.maxReplicas}')

    if [ "$STAGING_MIN" != "2" ]; then
        echo "FAIL: staging minReplicas expected 2, got $STAGING_MIN"
        ERRORS=$((ERRORS + 1))
    else
        echo "PASS: staging minReplicas=2"
    fi

    if [ "$STAGING_MAX" != "4" ]; then
        echo "FAIL: staging maxReplicas expected 4, got $STAGING_MAX"
        ERRORS=$((ERRORS + 1))
    else
        echo "PASS: staging maxReplicas=4"
    fi

    # Check CPU target - handle both v2 jsonpath structures
    STAGING_CPU=$(kubectl get hpa web-frontend -n web-staging -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}')
    if [ -z "$STAGING_CPU" ]; then
        STAGING_CPU=$(kubectl get hpa web-frontend -n web-staging -o jsonpath='{.spec.targetCPUUtilizationPercentage}')
    fi
    if [ "$STAGING_CPU" != "50" ]; then
        echo "FAIL: staging CPU target expected 50, got $STAGING_CPU"
        ERRORS=$((ERRORS + 1))
    else
        echo "PASS: staging CPU target=50%"
    fi
fi

if ! kubectl get deployment web-frontend -n web-staging >/dev/null 2>&1; then
    echo "FAIL: Deployment 'web-frontend' not found in namespace web-staging"
    ERRORS=$((ERRORS + 1))
else
    echo "PASS: Staging deployment exists"
fi

# 3. Check prod overlay
echo ""
echo "--- Prod ---"
if ! kubectl get hpa web-frontend -n web-prod >/dev/null 2>&1; then
    echo "FAIL: HPA 'web-frontend' not found in namespace web-prod"
    ERRORS=$((ERRORS + 1))
else
    PROD_MIN=$(kubectl get hpa web-frontend -n web-prod -o jsonpath='{.spec.minReplicas}')
    PROD_MAX=$(kubectl get hpa web-frontend -n web-prod -o jsonpath='{.spec.maxReplicas}')

    if [ "$PROD_MIN" != "3" ]; then
        echo "FAIL: prod minReplicas expected 3, got $PROD_MIN"
        ERRORS=$((ERRORS + 1))
    else
        echo "PASS: prod minReplicas=3"
    fi

    if [ "$PROD_MAX" != "8" ]; then
        echo "FAIL: prod maxReplicas expected 8, got $PROD_MAX"
        ERRORS=$((ERRORS + 1))
    else
        echo "PASS: prod maxReplicas=8"
    fi

    PROD_CPU=$(kubectl get hpa web-frontend -n web-prod -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}')
    if [ -z "$PROD_CPU" ]; then
        PROD_CPU=$(kubectl get hpa web-frontend -n web-prod -o jsonpath='{.spec.targetCPUUtilizationPercentage}')
    fi
    if [ "$PROD_CPU" != "40" ]; then
        echo "FAIL: prod CPU target expected 40, got $PROD_CPU"
        ERRORS=$((ERRORS + 1))
    else
        echo "PASS: prod CPU target=40%"
    fi
fi

if ! kubectl get deployment web-frontend -n web-prod >/dev/null 2>&1; then
    echo "FAIL: Deployment 'web-frontend' not found in namespace web-prod"
    ERRORS=$((ERRORS + 1))
else
    echo "PASS: Prod deployment exists"
fi

echo ""
if [ $ERRORS -gt 0 ]; then
    echo "FAIL: $ERRORS error(s) found"
    exit 1
fi

echo "SUCCESS: Kustomize HPA overlays correctly configured and deployed"
