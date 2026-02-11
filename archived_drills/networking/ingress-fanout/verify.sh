#!/bin/bash
# Verify for ingress-fanout drill

# Check Rules
VIDEO_RULE=$(kubectl get ingress fanout -o jsonpath='{.spec.rules[*].http.paths[?(@.path=="/video")].backend.service.name}')
STREAM_RULE=$(kubectl get ingress fanout -o jsonpath='{.spec.rules[*].http.paths[?(@.path=="/stream")].backend.service.name}')

if [[ "$VIDEO_RULE" == "video-service" ]] && [[ "$STREAM_RULE" == "stream-service" ]]; then
    echo "SUCCESS: Ingress rules are correct."
    exit 0
else
    echo "FAILURE: Ingress rules are incorrect."
    echo "Got video->'$VIDEO_RULE' (expected video-service) and stream->'$STREAM_RULE' (expected stream-service)"
    exit 1
fi
