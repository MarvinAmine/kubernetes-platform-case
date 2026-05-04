#!/usr/bin/env bash
set -euo pipefail

APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-local}"
POSTGRES_DEPLOYMENT_NAME="${POSTGRES_DEPLOYMENT_NAME:-payment-review-postgres}"
POSTGRES_SERVICE_NAME="${POSTGRES_SERVICE_NAME:-payment-review-postgres}"

kubectl delete service "$POSTGRES_SERVICE_NAME" -n "$APP_NAMESPACE" --ignore-not-found=true
kubectl delete deployment "$POSTGRES_DEPLOYMENT_NAME" -n "$APP_NAMESPACE" --ignore-not-found=true
