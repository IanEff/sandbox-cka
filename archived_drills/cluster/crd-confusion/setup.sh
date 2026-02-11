#!/bin/bash
set -e

# Create CRD
cat <<EOF | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.example.com
spec:
  group: example.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                speed:
                  type: integer
                  minimum: 1
                  maximum: 1000
                color:
                  type: string
                  enum:
                  - red
                  - blue
                  - green
              required:
              - speed
              - color
  scope: Namespaced
  names:
    plural: widgets
    singular: widget
    kind: Widget
    shortNames:
    - wdg
EOF
