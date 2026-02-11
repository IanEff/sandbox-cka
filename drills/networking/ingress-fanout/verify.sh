#!/bin/bash

# Check if Ingress exists
if ! kubectl get ingress shop-ingress > /dev/null 2>&1; then
  echo "FAIL: Ingress 'shop-ingress' not found."
  exit 1
fi

# Check /products rule
PRODUCTS_BACKEND=$(kubectl get ingress shop-ingress -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/products")].backend.service.name}')
if [ "$PRODUCTS_BACKEND" != "products-svc" ]; then
    # Try looking in other rules/indices just in case, but usually [0] is enough for simple single-host or no-host ingress
    echo "FAIL: /products path does not point to products-svc (found '$PRODUCTS_BACKEND')"
    exit 1
fi

# Check /checkout rule
CHECKOUT_BACKEND=$(kubectl get ingress shop-ingress -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/checkout")].backend.service.name}')
if [ "$CHECKOUT_BACKEND" != "checkout-svc" ]; then
    echo "FAIL: /checkout path does not point to checkout-svc (found '$CHECKOUT_BACKEND')"
    exit 1
fi

# Check pathType (optional but good practice)
PATH_TYPE=$(kubectl get ingress shop-ingress -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/products")].pathType}')
if [ "$PATH_TYPE" != "ImplementationSpecific" ]; then
    echo "WARNING: pathType is $PATH_TYPE, expected ImplementationSpecific (strictly speaking)"
    # Don't fail on this as it's minor
fi

echo "SUCCESS: Ingress configured correctly."
