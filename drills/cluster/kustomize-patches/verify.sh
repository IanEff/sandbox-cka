#!/bin/bash
# Verify for kustomize-patches

# Check command
cmd=$(kubectl get deploy sleep-deploy -o jsonpath='{.spec.template.spec.containers[0].command[0]}')
arg=$(kubectl get deploy sleep-deploy -o jsonpath='{.spec.template.spec.containers[0].command[2]}')

# They might do ["sh", "-c", "sleep 3600"] or just ["sleep", "3600"]
# We will check if "sleep" is in the command or args.
full_cmd=$(kubectl get deploy sleep-deploy -o jsonpath='{.spec.template.spec.containers[0].command}')

if [[ "$full_cmd" == *"sleep"* ]]; then
    echo "Sleep command found."
    exit 0
else
    echo "Command does not appear to be patched to sleep: $full_cmd"
    exit 1
fi
