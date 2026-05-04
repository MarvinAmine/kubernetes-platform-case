#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-local}"
MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
APP_RELEASE_NAME="${APP_RELEASE_NAME:-payment-exception-review-service}"
APP_IMAGE_REPOSITORY="${APP_IMAGE_REPOSITORY:-payment-exception-review-service}"
APP_IMAGE_TAG="${APP_IMAGE_TAG:-local}"
APP_IMAGE_PULL_POLICY="${APP_IMAGE_PULL_POLICY:-IfNotPresent}"
APP_PLATFORM_NAMESPACE="${APP_PLATFORM_NAMESPACE:-$APP_NAMESPACE}"
APP_DATABASE_HOST="${APP_DATABASE_HOST:-${POSTGRES_SERVICE_NAME:-payment-review-postgres}}"
APP_DATABASE_NAME="${APP_DATABASE_NAME:-${POSTGRES_DATABASE_NAME:-payment_exception_review}}"
APP_DATABASE_USERNAME="${APP_DATABASE_USERNAME:-${POSTGRES_LOCAL_USERNAME:-postgres}}"
APP_DATABASE_SSL_MODE="${APP_DATABASE_SSL_MODE:-disable}"
POSTGRES_SERVICE_NAME="${POSTGRES_SERVICE_NAME:-payment-review-postgres}"
POSTGRES_DATABASE_NAME="${POSTGRES_DATABASE_NAME:-payment_exception_review}"
POSTGRES_LOCAL_USERNAME="${POSTGRES_LOCAL_USERNAME:-postgres}"

helm upgrade --install "$APP_RELEASE_NAME" \
    "$APP_ROOT/helm" \
    --namespace "$APP_NAMESPACE" \
    --set image.repository="${APP_IMAGE_REPOSITORY}" \
    --set image.tag="${APP_IMAGE_TAG}" \
    --set image.pullPolicy="${APP_IMAGE_PULL_POLICY}" \
    --set platform.namespace="${APP_PLATFORM_NAMESPACE}" \
    --set database.host="${APP_DATABASE_HOST}" \
    --set database.name="${APP_DATABASE_NAME}" \
    --set database.username="${APP_DATABASE_USERNAME}" \
    --set database.sslMode="${APP_DATABASE_SSL_MODE}" \
    --set monitoring.namespace="${MONITORING_NAMESPACE}"

kubectl rollout status deployment/"$APP_RELEASE_NAME" -n "$APP_NAMESPACE" --timeout=180s
