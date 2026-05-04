#!/usr/bin/env bash
set -euo pipefail

APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-stage1}"
DB_PASSWORD_SECRET_NAME="${DB_PASSWORD_SECRET_NAME:-payment-review-db}"

if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is required but was not found in PATH."
    exit 1
fi

if kubectl get secret "${DB_PASSWORD_SECRET_NAME}" --namespace "${APP_NAMESPACE}" >/dev/null 2>&1; then
    echo "Removing runtime database password secret..."
    echo "Namespace: ${APP_NAMESPACE}"
    echo "Secret name: ${DB_PASSWORD_SECRET_NAME}"
    kubectl delete secret "${DB_PASSWORD_SECRET_NAME}" --namespace "${APP_NAMESPACE}"
    echo "Runtime database password secret removed successfully."
else
    echo "Runtime database password secret ${DB_PASSWORD_SECRET_NAME} does not exist in namespace ${APP_NAMESPACE}. Skipping."
fi
