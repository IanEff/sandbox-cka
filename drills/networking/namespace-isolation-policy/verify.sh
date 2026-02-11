#!/bin/bash
kubectl get netpol deny-all-ingress-from-other-ns -n project-a -o json | jq -e '
.spec.podSelector == {} and
(.spec.ingress | length > 0) and
(.spec.ingress[0].from | length > 0) and
(.spec.ingress[0].from[0].podSelector == {}) and
(.spec.ingress[0].from[0].namespaceSelector == null)
' > /dev/null
