#!/usr/bin/env bash
set -euo pipefail

APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-local}"

kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ${APP_NAMESPACE}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-runtime-sa
  namespace: ${APP_NAMESPACE}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-runtime-role
  namespace: ${APP_NAMESPACE}
rules:
  - apiGroups: [""]
    resources: ["configmaps", "secrets"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-runtime-rb
  namespace: ${APP_NAMESPACE}
subjects:
  - kind: ServiceAccount
    name: app-runtime-sa
    namespace: ${APP_NAMESPACE}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: app-runtime-role
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: platform-baseline-config
  namespace: ${APP_NAMESPACE}
data:
  ENV_NAME: local
  PLATFORM_OWNER: platform-team
  LOG_LEVEL: INFO
EOF
