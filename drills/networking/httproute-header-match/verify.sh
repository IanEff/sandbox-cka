#!/bin/bash
# Verify for httproute-header-match

# Structural verification of the HTTPRoute logic.

JSON=$(kubectl get httproute mobile-route -n gateway-test -o json 2>/dev/null)

if [ -z "$JSON" ]; then
    echo "FAIL: HTTPRoute 'mobile-route' not found in namespace 'gateway-test'."
    exit 1
fi

# Check Header Match
HEADER_MATCH=$(echo "$JSON" | jq -r '.spec.rules[] | select(.matches[0].headers[0].name == "User-Agent" and .matches[0].headers[0].value == "Android") | .backendRefs[0].name')

if [ "$HEADER_MATCH" != "android-service" ]; then
    echo "Rule for User-Agent: Android not pointing to android-service. Found: $HEADER_MATCH"
    exit 1
fi

# Check Default Backend (Rule with no matches)
DEFAULT_MATCH=$(echo "$JSON" | jq -r '.spec.rules[] | select(.matches == null) | .backendRefs[0].name')
# Check for null matches (catch-all)
if [ "$DEFAULT_MATCH" == "null" ]; then
    # Try checking for empty match list
    DEFAULT_MATCH=$(echo "$JSON" | jq -r '.spec.rules[] | select(.matches == []) | .backendRefs[0].name')
fi

# If user implemented match "/" path prefix for default, that's also valid.
if [ "$DEFAULT_MATCH" == "" ] || [ "$DEFAULT_MATCH" == "null" ]; then
    # Try Path Prefix / (ensure no headers are present)
    DEFAULT_MATCH=$(echo "$JSON" | jq -r '.spec.rules[] | select(.matches[0].path.value == "/" and .matches[0].headers == null) | .backendRefs[0].name')
fi

if [ "$DEFAULT_MATCH" != "web-service" ]; then
    echo "Default rule (no header or path /) not pointing to web-service. Found: $DEFAULT_MATCH"
    exit 1
fi

echo "Configuration looks correct."
exit 0
