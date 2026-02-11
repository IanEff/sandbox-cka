#!/bin/bash

# Check Ingress Exists
if ! kubectl get ingress example-ingress > /dev/null 2>&1; then
    echo "Ingress 'example-ingress' not found."
    exit 1
fi

# Check Foo Path
FOO_SVC=$(kubectl get ingress example-ingress -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/foo")].backend.service.name}')
FOO_PORT=$(kubectl get ingress example-ingress -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/foo")].backend.service.port.number}')

if [ "$FOO_SVC" != "foo-service" ] || [ "$FOO_PORT" != "8080" ]; then
    echo "Path /foo is not correctly routed to foo-service:8080."
    exit 1
fi

# Check Bar Path
BAR_SVC=$(kubectl get ingress example-ingress -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/bar")].backend.service.name}')
BAR_PORT=$(kubectl get ingress example-ingress -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/bar")].backend.service.port.number}')

if [ "$BAR_SVC" != "bar-service" ] || [ "$BAR_PORT" != "9090" ]; then
    echo "Path /bar is not correctly routed to bar-service:9090."
    exit 1
fi

echo "Ingress details correct."
exit 0
