#!/bin/bash
TYPE=$(kubectl get svc external-db -o jsonpath='{.spec.type}')
NAME=$(kubectl get svc external-db -o jsonpath='{.spec.externalName}')

if [[ "$TYPE" != "ExternalName" ]]; then echo "Wrong type"; exit 1; fi
if [[ "$NAME" != "db.example.com" ]]; then echo "Wrong externalName"; exit 1; fi
