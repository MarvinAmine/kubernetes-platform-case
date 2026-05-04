#!/usr/bin/env bash
set -euo pipefail

# Applies the runtime PostgreSQL password secret expected by the application
# Helm chart. The secret contract is versioned in this script while the actual
# password value is injected at runtime from .env locally or GitHub Actions in CI.

APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-stage1}"
DB_PASSWORD_SECRET_NAME="${DB_PASSWORD_SECRET_NAME:-payment-review-db}"
DB_PASSWORD_SECRET_KEY="${DB_PASSWORD_SECRET_KEY:-POSTGRES_ADMIN_PASSWORD}"
DB_PASSWORD_SECRET_VALUE="${DB_PASSWORD_SECRET_VALUE:-${POSTGRES_ADMIN_PASSWORD:-}}"

DB_PASSWORD_SECRET_VALUE="${DB_PASSWORD_SECRET_VALUE:?DB_PASSWORD_SECRET_VALUE is required (or set POSTGRES_ADMIN_PASSWORD for local/bootstrap compatibility)}"

if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is required but was not found in PATH."
    exit 1
fi

echo "Applying runtime database password secret..."
echo "Namespace: ${APP_NAMESPACE}"
echo "Secret name: ${DB_PASSWORD_SECRET_NAME}"
echo "Secret key: ${DB_PASSWORD_SECRET_KEY}"

kubectl create secret generic "${DB_PASSWORD_SECRET_NAME}" \
    --namespace "${APP_NAMESPACE}" \
    --from-literal="${DB_PASSWORD_SECRET_KEY}=${DB_PASSWORD_SECRET_VALUE}" \
    --dry-run=client \
    -o yaml | kubectl apply -f -

kubectl label secret "${DB_PASSWORD_SECRET_NAME}" \
    --namespace "${APP_NAMESPACE}" \
    app.kubernetes.io/managed-by=platform-runtime-secret-flow \
    app.kubernetes.io/part-of=payment-exception-review-service \
    platform.openai.dev/owner=platform-team \
    --overwrite >/dev/null

echo "Runtime database password secret applied successfully."
